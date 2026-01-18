module Webhooks
  class MuralPayController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      event_type = params[:event] || params[:type]
      payload = params[:data] || params

      case event_type
      when "transaction.completed", "TRANSACTION_COMPLETED"
        handle_transaction_completed(payload)
      when "payout.completed", "PAYOUT_COMPLETED"
        handle_payout_completed(payload)
      when "payout.failed", "PAYOUT_FAILED"
        handle_payout_failed(payload)
      else
        Rails.logger.info "Unhandled Mural Pay webhook event: #{event_type}"
      end

      head :ok
    end

    private

    def handle_transaction_completed(payload)
      transaction_id = payload[:transactionId] || payload[:id]
      ProcessPaymentJob.perform_later(transaction_id) if transaction_id
    end

    def handle_payout_completed(payload)
      payout_id = payload[:payoutId] || payload[:id]
      UpdatePayoutStatusJob.perform_later(payout_id, "completed") if payout_id
    end

    def handle_payout_failed(payload)
      payout_id = payload[:payoutId] || payload[:id]
      error = payload[:error] || payload[:message]
      UpdatePayoutStatusJob.perform_later(payout_id, "failed", error) if payout_id
    end

    def verify_webhook_signature
      signature = request.headers["X-Mural-Signature"]
      secret = ENV["MURAL_WEBHOOK_SECRET"]

      return true if secret.blank?

      expected = OpenSSL::HMAC.hexdigest("SHA256", secret, request.raw_post)
      ActiveSupport::SecurityUtils.secure_compare(signature.to_s, expected)
    end
  end
end
