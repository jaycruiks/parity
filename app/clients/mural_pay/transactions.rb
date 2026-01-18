module MuralPay
  class Transactions < Base
    def find(id)
      get("/api/transactions/#{id}")
    end

    def search(account_id:, status: nil, from_date: nil, to_date: nil, limit: 100)
      post("/api/transactions/search/account/#{account_id}", {
        status: status,
        fromDate: from_date&.iso8601,
        toDate: to_date&.iso8601,
        limit: limit
      }.compact)
    end

    def completed_since(account_id:, since:)
      search(
        account_id: account_id,
        status: "COMPLETED",
        from_date: since
      )
    end
  end
end
