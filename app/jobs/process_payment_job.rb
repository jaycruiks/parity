class ProcessPaymentJob < ApplicationJob
  queue_as :default

  def perform(transaction_id)
    return if Payment.exists?(mural_transaction_id: transaction_id)

    transaction_data = fetch_transaction(transaction_id)
    return unless transaction_data

    matcher = PaymentMatcher.new(transaction_data)
    order = matcher.match

    unless order
      Rails.logger.warn "No matching order found for transaction #{transaction_id}"
      return
    end

    payment = matcher.create_payment!(order)
    payment.mark_confirmed!

    trigger_payout_if_enabled(order)
  end

  private

  def fetch_transaction(transaction_id)
    client = MuralPay::Transactions.new
    response = client.find(transaction_id)
    response["transaction"] || response
  rescue => e
    Rails.logger.error "Failed to fetch transaction #{transaction_id}: #{e.message}"
    nil
  end

  def trigger_payout_if_enabled(order)
    settings = MerchantSetting.current
    return unless settings.auto_convert_enabled?
    return unless settings.payout_configured?

    InitiatePayoutJob.perform_later(order.id)
  end
end
