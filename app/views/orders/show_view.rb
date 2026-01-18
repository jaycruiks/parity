class Views::Orders::ShowView < Views::Base
  def initialize(order:)
    @order = order
  end

  def view_template
    div(class: "min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50") do
      div(class: "max-w-2xl mx-auto px-4 py-12") do
        header_section
        div(class: "space-y-6") do
          payment_instructions_card if @order.payment_requested?
          payment_confirmed_card if @order.paid? || @order.converting? || @order.withdrawn?
          order_status_card
          shipping_details_card
          order_items_card
          continue_shopping_button
        end
      end
    end
  end

  private

  def header_section
    if @order.payment_requested?
      payment_pending_header
    else
      success_header
    end
  end

  def payment_pending_header
    div(class: "text-center mb-10") do
      div(class: "w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4") do
        span(class: "text-4xl") { "💳" }
      end
      h1(class: "text-3xl font-bold text-gray-900 mb-2") { "Complete Your Payment" }
      p(class: "text-gray-600") { "Order ##{@order.id}" }
    end
  end

  def success_header
    div(class: "text-center mb-10") do
      div(class: "w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4") do
        span(class: "text-4xl") { "✓" }
      end
      h1(class: "text-3xl font-bold text-gray-900 mb-2") { "Order Confirmed!" }
      p(class: "text-gray-600") { "Order ##{@order.id}" }
    end
  end

  def payment_instructions_card
    div(class: "bg-gradient-to-br from-blue-50 to-indigo-50 rounded-2xl shadow-md border border-blue-200 p-6", data: { controller: "payment-status", payment_status_order_id_value: @order.id }) do
      h2(class: "font-bold text-gray-900 mb-4 flex items-center gap-2") do
        span { "⚡" }
        span { "Payment Instructions" }
      end

      div(class: "space-y-4") do
        # Amount to send
        div(class: "bg-white rounded-xl p-4 border border-blue-100") do
          p(class: "text-sm text-gray-500 mb-1") { "Amount to Send (USDC)" }
          div(class: "flex items-center justify-between") do
            span(class: "text-2xl font-bold text-indigo-600") { format_usdc(@order.deposit_amount_usdc) }
            button(
              type: "button",
              class: "px-3 py-1 bg-indigo-100 text-indigo-700 rounded-lg text-sm font-medium hover:bg-indigo-200 transition-colors",
              data: { action: "click->payment-status#copyAmount", copy_value: @order.deposit_amount_usdc.to_s }
            ) { "Copy" }
          end
        end

        # Wallet address
        div(class: "bg-white rounded-xl p-4 border border-blue-100") do
          p(class: "text-sm text-gray-500 mb-1") { "Send to Wallet Address (Polygon Network)" }
          div(class: "flex items-center gap-2") do
            code(class: "flex-1 text-sm font-mono bg-gray-100 p-3 rounded-lg break-all text-gray-700") do
              @order.deposit_wallet_address || "Wallet not configured"
            end
            button(
              type: "button",
              class: "px-3 py-2 bg-indigo-100 text-indigo-700 rounded-lg text-sm font-medium hover:bg-indigo-200 transition-colors shrink-0",
              data: { action: "click->payment-status#copyAddress", copy_value: @order.deposit_wallet_address }
            ) { "Copy" }
          end
        end

        # Network warning
        div(class: "bg-amber-50 border border-amber-200 rounded-xl p-4") do
          div(class: "flex items-start gap-2") do
            span(class: "text-amber-500") { "⚠️" }
            div do
              p(class: "text-sm font-medium text-amber-800") { "Important" }
              p(class: "text-sm text-amber-700") do
                "Send exactly #{format_usdc(@order.deposit_amount_usdc)} USDC on the Polygon network. Sending a different amount or using a different network may result in lost funds."
              end
            end
          end
        end

        # Status polling indicator
        div(class: "text-center text-sm text-gray-500", data: { payment_status_target: "statusMessage" }) do
          span(class: "inline-flex items-center gap-2") do
            span(class: "animate-pulse") { "●" }
            span { "Waiting for payment..." }
          end
        end
      end
    end
  end

  def payment_confirmed_card
    div(class: "bg-gradient-to-br from-green-50 to-emerald-50 rounded-2xl shadow-md border border-green-200 p-6") do
      div(class: "flex items-center gap-3") do
        div(class: "w-12 h-12 bg-green-100 rounded-full flex items-center justify-center") do
          span(class: "text-2xl") { "✓" }
        end
        div do
          h3(class: "font-bold text-green-800") { "Payment Received!" }
          p(class: "text-sm text-green-600") do
            if @order.converting?
              "Converting to COP and processing withdrawal..."
            elsif @order.withdrawn?
              "Funds have been converted and withdrawn."
            else
              "Your payment has been confirmed."
            end
          end
        end
      end
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

  def format_usdc(amount)
    return "0.0000 USDC" if amount.nil?
    "#{sprintf('%.4f', amount)} USDC"
  end
end
