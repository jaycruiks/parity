class OrdersController < ApplicationController
  def new
    cart_items = cart_items_with_products
    return redirect_to cart_path, alert: "Your cart is empty" if cart_items.empty?

    order = Order.new
    total_cents = cart_items.sum { |item| item[:product].price_cents * item[:quantity] }
    render Views::Orders::NewView.new(order: order, cart_items: cart_items, total_cents: total_cents)
  end

  def create
    @order = Order.new(order_params)
    cart_items = cart_items_with_products

    if cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty"
      return
    end

    @order.total_cents = cart_items.sum { |item| item[:product].price_cents * item[:quantity] }

    Order.transaction do
      @order.save!
      cart_items.each do |item|
        @order.order_items.create!(
          product: item[:product],
          quantity: item[:quantity],
          price_cents: item[:product].price_cents
        )
        item[:product].decrement!(:inventory_count, item[:quantity])
      end
    end

    session.delete(:cart)
    redirect_to @order, notice: "Order placed successfully!"
  rescue ActiveRecord::RecordInvalid => e
    total_cents = cart_items.sum { |item| item[:product].price_cents * item[:quantity] }
    render Views::Orders::NewView.new(order: @order, cart_items: cart_items, total_cents: total_cents), status: :unprocessable_entity
  end

  def show
    order = Order.includes(order_items: :product).find(params[:id])
    render Views::Orders::ShowView.new(order: order)
  end

  private

  def order_params
    params.require(:order).permit(:email, :shipping_address)
  end

  def cart_items_with_products
    cart = session[:cart] || {}
    return [] if cart.empty?

    products = Product.where(id: cart.keys).index_by(&:id)
    cart.map do |product_id, quantity|
      product = products[product_id.to_i]
      next unless product
      { product: product, quantity: quantity }
    end.compact
  end
end