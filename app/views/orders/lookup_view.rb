class Views::Orders::LookupView < Views::Base
  def initialize(orders:, email:, error: nil)
    @orders = orders
    @email = email
    @error = error
  end

  def view_template
    div(class: "min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50") do
      div(class: "max-w-2xl mx-auto px-4 py-12") do
        header_section
        search_form
        error_message if @error
        results_section if @email && @error.nil?
      end
    end
  end

  private

  def header_section
    div(class: "text-center mb-10") do
      div(class: "w-20 h-20 bg-indigo-100 rounded-full flex items-center justify-center mx-auto mb-4") do
        span(class: "text-4xl") { "🔍" }
      end
      h1(class: "text-3xl font-bold text-gray-900 mb-2") { "Find Your Order" }
      p(class: "text-gray-600") { "Enter your email to view your orders" }
    end
  end

  def search_form
    div(class: "bg-white rounded-2xl shadow-md border border-gray-200 p-6 mb-6") do
      form(action: search_orders_path, method: "get", class: "flex gap-3") do
        input(
          type: "email",
          name: "email",
          value: @email,
          placeholder: "your@email.com",
          required: true,
          class: "flex-1 px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none"
        )
        button(
          type: "submit",
          class: "px-6 py-3 bg-indigo-600 text-white rounded-xl font-semibold hover:bg-indigo-700 transition-colors"
        ) { "Search" }
      end
    end
  end

  def error_message
    div(class: "bg-red-50 border border-red-200 rounded-xl p-4 mb-6") do
      p(class: "text-red-700") { @error }
    end
  end

  def results_section
    if @orders.empty?
      no_orders_found
    else
      orders_list
    end
  end

  def no_orders_found
    div(class: "bg-white rounded-2xl shadow-md border border-gray-200 p-8 text-center") do
      p(class: "text-gray-600 mb-4") { "No orders found for #{@email}" }
      link_to "Start Shopping", products_path,
        class: "inline-block px-6 py-3 bg-indigo-600 text-white rounded-xl font-semibold hover:bg-indigo-700 transition-colors"
    end
  end

  def orders_list
    div(class: "space-y-4") do
      @orders.each do |order|
        order_card(order)
      end
    end
  end

  def order_card(order)
    link_to order_path(order), class: "block bg-white rounded-2xl shadow-md border border-gray-200 p-6 hover:shadow-lg transition-shadow" do
      div(class: "flex justify-between items-start mb-4") do
        div do
          h3(class: "font-bold text-gray-900") { "Order ##{order.id}" }
          p(class: "text-sm text-gray-500") { order.created_at.strftime("%B %d, %Y at %I:%M %p") }
        end
        status_badge(order)
      end

      div(class: "flex justify-between items-center pt-4 border-t border-gray-100") do
        span(class: "text-gray-600") { "#{order.order_items.size} item(s)" }
        span(class: "font-bold text-indigo-600") { format_price(order.total_cents) }
      end

      if order.payment_requested?
        div(class: "mt-4 bg-blue-50 border border-blue-200 rounded-xl p-3") do
          p(class: "text-sm text-blue-700 font-medium") { "Payment pending - click to view payment instructions" }
        end
      end
    end
  end

  def status_badge(order)
    colors = {
      "pending" => "bg-yellow-100 text-yellow-800 border-yellow-200",
      "payment_requested" => "bg-blue-100 text-blue-800 border-blue-200",
      "paid" => "bg-green-100 text-green-800 border-green-200",
      "converting" => "bg-purple-100 text-purple-800 border-purple-200",
      "withdrawn" => "bg-green-100 text-green-800 border-green-200",
      "failed" => "bg-red-100 text-red-800 border-red-200"
    }

    span(class: "px-3 py-1 rounded-full text-sm font-semibold border #{colors[order.status]}") do
      order.status.humanize
    end
  end

  def format_price(cents)
    "$#{sprintf('%.2f', cents / 100.0)}"
  end
end
