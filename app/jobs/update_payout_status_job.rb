class UpdatePayoutStatusJob < ApplicationJob
  queue_as :default

  def perform(payout_id, status, error_message = nil)
    withdrawal = Withdrawal.find_by(mural_payout_id: payout_id)
    return unless withdrawal

    case status
    when "completed"
      handle_completed(withdrawal, payout_id)
    when "failed"
      handle_failed(withdrawal, error_message)
    end
  end

  private

  def handle_completed(withdrawal, payout_id)
    payout_details = fetch_payout_details(payout_id)

    withdrawal.update!(
      status: :completed,
      amount_cop: payout_details&.dig("fiatAmount"),
      exchange_rate: payout_details&.dig("exchangeRate")
    )

    withdrawal.order.withdrawn!
  end

  def handle_failed(withdrawal, error_message)
    withdrawal.update!(
      status: :failed,
      error_message: error_message
    )

    withdrawal.order.failed!
  end

  def fetch_payout_details(payout_id)
    client = MuralPay::Payouts.new
    client.find(payout_id)
  rescue => e
    Rails.logger.error "Failed to fetch payout details #{payout_id}: #{e.message}"
    nil
  end
end
