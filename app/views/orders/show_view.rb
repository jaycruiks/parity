class Views::Orders::ShowView < Views::Base
  def initialize(order:)
    @order = order
  end

  def view_template
    div(class: "min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50") do
      div(class: "max-w-2xl mx-auto px-4 py-12") do
        success_header
        div(class: "space-y-6") do
          order_status_card
          shipping_details_card
          order_items_card
          continue_shopping_button
        end
      end
    end
  end

  private

  def success_header
    div(class: "text-center mb-10") do
      div(class: "w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4") do
        span(class: "text-4xl") { "✓" }
      end
      h1(class: "text-3xl font-bold text-gray-900 mb-2") { "Order Confirmed!" }
      p(class: "text-gray-600") { "Order ##{@order.id}" }
    end
  end

  def order_status_card
    div(class: "bg-white rounded-2xl shadow-md border border-gray-200 p-6") do
      div(class: "flex justify-between items-center") do
        span(class: "font-semibold text-gray-700") { "Status" }
        status_badge
      end
    end
  end

  def status_badge
    colors = {
      "pending" => "bg-yellow-100 text-yellow-800 border-yellow-200",
      "payment_requested" => "bg-blue-100 text-blue-800 border-blue-200",
      "paid" => "bg-green-100 text-green-800 border-green-200",
      "converting" => "bg-purple-100 text-purple-800 border-purple-200",
      "withdrawn" => "bg-green-100 text-green-800 border-green-200",
      "failed" => "bg-red-100 text-red-800 border-red-200"
    }

    span(class: "px-4 py-2 rounded-full text-sm font-semibold border #{colors[@order.status]}") do
      @order.status.humanize
    end
  end

  def shipping_details_card
    div(class: "bg-white rounded-2xl shadow-md border border-gray-200 p-6") do
      h2(class: "font-bold text-gray-900 mb-4 pb-3 border-b border-gray-200") { "Shipping Details" }
      div(class: "space-y-2") do
        div(class: "flex items-center gap-2 text-gray-600") do
          span { "📧" }
          span { @order.email }
        end
        div(class: "flex items-start gap-2 text-gray-600") do
          span { "📍" }
          p(class: "whitespace-pre-line") { @order.shipping_address }
        end
      end
    end
  end

  def order_items_card
    div(class: "bg-white rounded-2xl shadow-md border border-gray-200 overflow-hidden") do
      div(class: "p-6 border-b border-gray-200") do
        h2(class: "font-bold text-gray-900") { "Order Items" }
      end

      @order.order_items.each do |item|
        div(class: "p-5 flex justify-between items-center border-b border-gray-100 last:border-b-0") do
          div(class: "flex items-center gap-4") do
            div(class: "w-12 h-12 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl flex items-center justify-center") do
              span(class: "text-xl") { "📦" }
            end
            div do
              span(class: "font-medium text-gray-900") { item.product.name }
              span(class: "text-gray-500 text-sm block") { "Qty: #{item.quantity}" }
            end
          end
          span(class: "font-semibold text-gray-900") { format_price(item.price_cents * item.quantity) }
        end
      end

      div(class: "p-6 bg-gray-50 flex justify-between items-center") do
        span(class: "text-xl font-bold text-gray-900") { "Total" }
        span(class: "text-2xl font-bold text-indigo-600") { format_price(@order.total_cents) }
      end
    end
  end

  def continue_shopping_button
    div(class: "text-center pt-4") do
      link_to "Continue Shopping", products_path,
        class: "inline-block px-8 py-4 bg-indigo-600 text-white rounded-xl font-semibold hover:bg-indigo-700 transition-colors shadow-lg"
    end
  end

  def format_price(cents)
    "$#{sprintf('%.2f', cents / 100.0)}"
  end
end
