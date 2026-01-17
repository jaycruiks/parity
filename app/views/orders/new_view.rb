class Views::Orders::NewView < Views::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(order:, cart_items:, total_cents:)
    @order = order
    @cart_items = cart_items
    @total_cents = total_cents
  end

  def view_template
    div(class: "min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50") do
      div(class: "max-w-4xl mx-auto px-4 py-12") do
        header
        div(class: "grid md:grid-cols-2 gap-8") do
          checkout_form
          order_summary
        end
      end
    end
  end

  private

  def header
    div(class: "text-center mb-10") do
      span(class: "text-5xl mb-4 block") { "💳" }
      h1(class: "text-3xl font-bold text-gray-900") { "Checkout" }
    end
  end

  def checkout_form
    div(class: "bg-white rounded-2xl shadow-md border border-gray-200 p-8") do
      h2(class: "text-xl font-bold text-gray-900 mb-6 pb-4 border-b border-gray-200") { "Your Information" }

      form_with model: @order, class: "space-y-5" do |f|
        error_messages if @order.errors.any?

        div do
          f.label :email, class: "block font-medium text-gray-700 mb-2"
          f.email_field :email,
            class: "w-full border-2 border-gray-200 rounded-xl px-4 py-3 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 outline-none transition-all",
            placeholder: "you@example.com",
            required: true
        end

        div do
          f.label :shipping_address, class: "block font-medium text-gray-700 mb-2"
          f.text_area :shipping_address,
            rows: 4,
            class: "w-full border-2 border-gray-200 rounded-xl px-4 py-3 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 outline-none transition-all resize-none",
            placeholder: "Enter your shipping address",
            required: true
        end

        div(class: "pt-4") do
          f.submit "Place Order",
            class: "w-full py-4 bg-indigo-600 text-white rounded-xl font-semibold text-lg hover:bg-indigo-700 transition-colors shadow-lg hover:shadow-xl cursor-pointer"
        end
      end
    end
  end

  def error_messages
    div(class: "p-4 bg-red-50 border-2 border-red-200 rounded-xl mb-4") do
      ul(class: "list-disc list-inside text-red-600") do
        @order.errors.full_messages.each do |msg|
          li { msg }
        end
      end
    end
  end

  def order_summary
    div(class: "bg-white rounded-2xl shadow-md border border-gray-200 p-8 h-fit") do
      h2(class: "text-xl font-bold text-gray-900 mb-6 pb-4 border-b border-gray-200") { "Order Summary" }

      div(class: "space-y-4 mb-6") do
        @cart_items.each do |item|
          div(class: "flex justify-between items-center py-3 border-b border-gray-100") do
            div(class: "flex items-center gap-3") do
              div(class: "w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-lg flex items-center justify-center") do
                span(class: "text-sm") { "📦" }
              end
              div do
                span(class: "font-medium text-gray-900") { item[:product].name }
                span(class: "text-gray-500 text-sm block") { "Qty: #{item[:quantity]}" }
              end
            end
            span(class: "font-semibold text-gray-900") { format_price(item[:product].price_cents * item[:quantity]) }
          end
        end
      end

      div(class: "flex justify-between items-center pt-4 border-t-2 border-gray-200") do
        span(class: "text-xl font-bold text-gray-900") { "Total" }
        span(class: "text-2xl font-bold text-indigo-600") { format_price(@total_cents) }
      end
    end
  end

  def format_price(cents)
    "$#{sprintf('%.2f', cents / 100.0)}"
  end
end
