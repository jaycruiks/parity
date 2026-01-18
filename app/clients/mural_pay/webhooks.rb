module MuralPay
  class Webhooks < Base
    def list
      get("/api/webhooks")
    end

    def find(id)
      get("/api/webhooks/#{id}")
    end

    def create(url:, categories:)
      post("/api/webhooks", {
        url: url,
        categories: categories
      })
    end

    def update(id, url: nil, categories: nil)
      patch("/api/webhooks/#{id}", {
        url: url,
        categories: categories
      }.compact)
    end

    def delete(id)
      super("/api/webhooks/#{id}")
    end

    def enable(id)
      update_status(id, "ACTIVE")
    end

    def disable(id)
      update_status(id, "DISABLED")
    end

    private

    def update_status(id, status)
      patch("/api/webhooks/#{id}/status", { status: status })
    end
  end
end
