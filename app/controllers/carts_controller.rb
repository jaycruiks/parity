class CartsController < ApplicationController
  def show
    cart_items = cart_items_with_products
    total_cents = cart_items.sum { |item| item[:product].price_cents * item[:quantity] }
    render Views::Carts::ShowView.new(cart_items: cart_items, total_cents: total_cents)
  end

  def add
    product = Product.find(params[:product_id])
    cart = session[:cart] ||= {}
    cart[product.id.to_s] = (cart[product.id.to_s] || 0) + 1

    redirect_to cart_path, notice: "#{product.name} added to cart"
  end

  def remove
    cart = session[:cart] ||= {}
    cart.delete(params[:product_id])

    redirect_to cart_path, notice: "Item removed from cart"
  end

  private

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