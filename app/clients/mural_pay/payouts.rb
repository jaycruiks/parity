module MuralPay
  class Payouts < Base
    def find(id)
      get("/api/payouts/#{id}")
    end

    def search(status: nil, limit: 100)
      post("/api/payouts/search", {
        status: status,
        limit: limit
      }.compact)
    end

    def create(source_account_id:, payouts:, memo: nil)
      post("/api/payouts/payout", {
        sourceAccountId: source_account_id,
        memo: memo,
        payouts: payouts
      }.compact)
    end

    def execute(id)
      post("/api/payouts/#{id}/execute", {})
    end

    def cancel(id)
      post("/api/payouts/#{id}/cancel", {})
    end

    def create_cop_payout(source_account_id:, counterparty_id:, payout_method_id:, usdc_amount:, memo: nil)
      create(
        source_account_id: source_account_id,
        memo: memo,
        payouts: [
          {
            counterpartyId: counterparty_id,
            payoutMethodId: payout_method_id,
            tokenAmount: usdc_amount,
            tokenSymbol: "USDC"
          }
        ]
      )
    end
  end
end
