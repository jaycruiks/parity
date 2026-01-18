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
      public_key_pem = ENV["MURAL_WEBHOOK_PUBLIC_KEY"]

      return true if public_key_pem.blank?

      # Decode the signature from base64
      signature_bytes = Base64.decode64(signature)

      # Load the public key
      public_key = OpenSSL::PKey::EC.new(public_key_pem)

      # Verify the signature using ECDSA with SHA256
      public_key.verify(OpenSSL::Digest::SHA256.new, signature_bytes, request.raw_post)
    rescue => e
      Rails.logger.error "Webhook signature verification failed: #{e.message}"
      false
    end
  end
end
