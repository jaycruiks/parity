module MuralPay
  class Accounts < Base
    def list
      get("/api/accounts")
    end

    def find(id)
      get("/api/accounts/#{id}")
    end

    def create(name:, description: nil)
      post("/api/accounts", {
        name: name,
        description: description
      }.compact)
    end

    def wallet_address(account_id)
      account = find(account_id)
      account.dig("accountDetails", "walletDetails", "walletAddress")
    end

    def balances(account_id)
      account = find(account_id)
      account.dig("accountDetails", "balances") || []
    end
  end
end