class Views::Carts::ShowView < Views::Base
  def initialize(cart_items:, total_cents:)
    @cart_items = cart_items
    @total_cents = total_cents
  end

  def view_template
    div(class: "min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50") do
      div(class: "max-w-2xl mx-auto px-4 py-12") do
        header
        if @cart_items.any?
          cart_content
        else
          empty_cart
        end
      end
    end
  end

  private

  def header
    div(class: "text-center mb-8") do
      span(class: "text-5xl mb-4 block") { "🛒" }
      h1(class: "text-3xl font-bold text-gray-900") { "Your Cart" }
    end
  end

  def cart_content
    div do
      cart_items_list
      cart_total
      cart_actions
    end
  end

  def cart_items_list
    div(class: "bg-white rounded-2xl shadow-md overflow-hidden mb-6") do
      @cart_items.each_with_index do |item, index|
        div(class: "p-5 flex justify-between items-center #{index > 0 ? 'border-t border-gray-100' : ''}") do
          div(class: "flex items-center gap-4") do
            div(class: "w-12 h-12 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl flex items-center justify-center") do
              span(class: "text-xl") { "📦" }
            end
            div do
              h3(class: "font-semibold text-gray-900") { item[:product].name }
              p(class: "text-sm text-gray-500") do
                "#{format_price(item[:product].price_cents)} × #{item[:quantity]}"
              end
            end
          end

          div(class: "flex items-center gap-4") do
            span(class: "font-bold text-indigo-600") { format_price(item[:product].price_cents * item[:quantity]) }
            button_to "Remove", remove_cart_path(item[:product]),
              method: :delete,
              class: "text-red-500 hover:text-red-700 hover:bg-red-50 px-3 py-1 rounded-lg transition-colors text-sm font-medium"
          end
        end
      end
    end
  end

  def cart_total
    div(class: "bg-white rounded-2xl shadow-md p-6 mb-6") do
      div(class: "flex justify-between items-center") do
        span(class: "text-xl font-semibold text-gray-900") { "Total" }
        span(class: "text-3xl font-bold text-indigo-600") { format_price(@total_cents) }
      end
    end
  end

  def cart_actions
    div(class: "flex gap-4") do
      link_to "Continue Shopping", products_path,
        class: "flex-1 text-center py-4 border-2 border-gray-200 text-gray-700 rounded-xl font-semibold hover:border-indigo-300 hover:text-indigo-600 transition-colors"
      link_to "Checkout", new_order_path,
        class: "flex-1 text-center py-4 bg-indigo-600 text-white rounded-xl font-semibold hover:bg-indigo-700 transition-colors shadow-lg"
    end
  end

  def empty_cart
    div(class: "text-center py-12 bg-white rounded-2xl shadow-md") do
      span(class: "text-6xl mb-4 block") { "🛒" }
      p(class: "text-gray-500 text-lg mb-6") { "Your cart is empty" }
      link_to "Browse Products", products_path,
        class: "inline-block px-6 py-3 bg-indigo-600 text-white rounded-xl font-semibold hover:bg-indigo-700 transition-colors"
    end
  end

  def format_price(cents)
    "$#{sprintf('%.2f', cents / 100.0)}"
  end
end
