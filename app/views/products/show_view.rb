class Views::Products::ShowView < Views::Base
  def initialize(product:)
    @product = product
  end

  def view_template
    div(class: "min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50") do
      div(class: "max-w-2xl mx-auto px-4 py-12") do
        nav_bar
        back_link
        product_detail
      end
    end
  end

  private

  def nav_bar
    div(class: "flex justify-end mb-8") do
      link_to cart_path, class: "flex items-center gap-2 text-gray-600 hover:text-indigo-600 font-medium transition-colors" do
        span(class: "text-xl") { "🛒" }
        span { "View Cart" }
      end
    end
  end

  def back_link
    link_to products_path, class: "inline-flex items-center text-indigo-600 hover:text-indigo-800 font-medium mb-8 group" do
      span(class: "mr-2 group-hover:-translate-x-1 transition-transform") { "←" }
      span { "Back to Products" }
    end
  end

  def product_detail
    div(class: "bg-white rounded-2xl shadow-lg overflow-hidden") do
      div(class: "h-48 bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center") do
        span(class: "text-7xl") { "📦" }
      end

      div(class: "p-8") do
        h1(class: "text-3xl font-bold text-gray-900 mb-4") { @product.name }
        p(class: "text-gray-600 mb-6 leading-relaxed") { @product.description }

        div(class: "flex justify-between items-center mb-8 p-4 bg-gray-50 rounded-xl") do
          div do
            span(class: "text-sm text-gray-500 block") { "Price" }
            span(class: "text-3xl font-bold text-indigo-600") { format_price(@product.price_cents) }
          end
          span(class: "px-4 py-2 bg-green-100 text-green-700 rounded-full font-medium") do
            "#{@product.inventory_count} in stock"
          end
        end

        add_to_cart_button
      end
    end
  end

  def add_to_cart_button
    if @product.inventory_count > 0
      button_to "Add to Cart", add_cart_path(@product),
        class: "w-full py-4 bg-indigo-600 text-white rounded-xl font-semibold text-lg hover:bg-indigo-700 transition-colors shadow-lg hover:shadow-xl"
    else
      button(disabled: true, class: "w-full py-4 bg-gray-300 text-gray-500 rounded-xl font-semibold text-lg cursor-not-allowed") do
        "Out of Stock"
      end
    end
  end

  def format_price(cents)
    "$#{sprintf('%.2f', cents / 100.0)}"
  end
end
