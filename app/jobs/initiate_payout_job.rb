class InitiatePayoutJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    return unless order.paid?
    return if order.withdrawal.present?

    settings = MerchantSetting.current
    return unless settings.payout_configured?

    payment = order.confirmed_payment
    return unless payment

    payout_response = create_payout(settings, payment.amount_usdc, order)
    return unless payout_response

    payout_id = payout_response["id"]
    execute_payout(payout_id)

    create_withdrawal(order, payout_id, payment.amount_usdc, settings)
    order.converting!
  end

  private

  def create_payout(settings, usdc_amount, order)
    client = MuralPay::Payouts.new
    client.create_cop_payout(
      source_account_id: settings.mural_account_id,
      counterparty_id: settings.mural_counterparty_id,
      payout_method_id: settings.mural_payout_method_id,
      usdc_amount: usdc_amount,
      memo: "Order ##{order.id}"
    )
  rescue => e
    Rails.logger.error "Failed to create payout for order #{order.id}: #{e.message}"
    nil
  end

  def execute_payout(payout_id)
    client = MuralPay::Payouts.new
    client.execute(payout_id)
  rescue => e
    Rails.logger.error "Failed to execute payout #{payout_id}: #{e.message}"
  end

  def create_withdrawal(order, payout_id, usdc_amount, settings)
    order.create_withdrawal!(
      mural_payout_id: payout_id,
      usdc_amount: usdc_amount,
      status: :processing,
      bank_account_info: {
        bank_name: settings.bank_name,
        bank_id: settings.bank_id,
        account_number: settings.bank_account_number,
        account_type: settings.account_type
      }.to_json
    )
  end
end
