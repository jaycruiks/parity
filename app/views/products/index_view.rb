class Views::Products::IndexView < Views::Base
  def initialize(products:)
    @products = products
  end

  def view_template
    div(class: "min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50") do
      div(class: "max-w-6xl mx-auto px-4 py-12") do
        nav_bar
        header
        if @products.any?
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8") do
            @products.each { |product| product_card(product) }
          end
        else
          empty_state
        end
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

  def header
    div(class: "text-center mb-12") do
      h1(class: "text-4xl font-bold text-gray-900 mb-4") { "Our Products" }
      p(class: "text-lg text-gray-600 max-w-2xl mx-auto") do
        "Browse our collection of quality items"
      end
    end
  end

  def product_card(product)
    div(class: "bg-white rounded-2xl shadow-md hover:shadow-xl transition-all duration-300 overflow-hidden border border-gray-100 group") do
      div(class: "h-32 bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center") do
        span(class: "text-5xl") { "📦" }
      end

      div(class: "p-6") do
        h2(class: "text-xl font-bold text-gray-900 mb-2 group-hover:text-indigo-600 transition-colors") { product.name }
        p(class: "text-gray-600 mb-4 line-clamp-2 text-sm") { product.description }

        div(class: "flex justify-between items-center mb-4") do
          span(class: "text-2xl font-bold text-indigo-600") { format_price(product.price_cents) }
          span(class: "text-xs font-medium px-2 py-1 bg-green-100 text-green-700 rounded-full") do
            "#{product.inventory_count} in stock"
          end
        end

        div(class: "flex gap-3") do
          link_to "View", product_path(product),
            class: "flex-1 text-center px-4 py-2.5 border-2 border-gray-200 text-gray-700 rounded-xl font-medium hover:border-indigo-300 hover:text-indigo-600 transition-colors"
          button_to "Add to Cart", add_cart_path(product),
            class: "flex-1 px-4 py-2.5 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 transition-colors shadow-md hover:shadow-lg"
        end
      end
    end
  end

  def empty_state
    div(class: "text-center py-16") do
      span(class: "text-6xl mb-4 block") { "🛒" }
      p(class: "text-gray-500 text-lg") { "No products available yet." }
    end
  end

  def format_price(cents)
    "$#{sprintf('%.2f', cents / 100.0)}"
  end
end
