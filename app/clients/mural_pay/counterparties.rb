module MuralPay
  class Counterparties < Base
    def find(id)
      get("/api/counterparties/counterparty/#{id}")
    end

    def search(limit: 100)
      post("/api/counterparties/search", { limit: limit })
    end

    def create_individual(first_name:, last_name:, email:, address:)
      post("/api/counterparties", {
        type: "individual",
        firstName: first_name,
        lastName: last_name,
        email: email,
        physicalAddress: format_address(address)
      })
    end

    def create_business(business_name:, email:, address:)
      post("/api/counterparties", {
        type: "business",
        businessName: business_name,
        email: email,
        physicalAddress: format_address(address)
      })
    end

    def supported_banks(payout_type:)
      get("/api/counterparties/payment-methods/supported-banks", {
        payoutMethodType: payout_type
      })
    end

    def create_payout_method(counterparty_id:, alias_name:, payout_method_details:)
      post("/api/counterparties/#{counterparty_id}/payout-methods", {
        alias: alias_name,
        payoutMethodDetails: payout_method_details
      })
    end

    def create_cop_domestic_payout_method(counterparty_id:, alias_name:, bank_id:, account_number:, account_type:, document_number:, document_type:, phone_number:)
      create_payout_method(
        counterparty_id: counterparty_id,
        alias_name: alias_name,
        payout_method_details: {
          type: "copDomestic",
          bankId: bank_id,
          bankAccountNumber: account_number,
          accountType: account_type,
          documentNumber: document_number,
          documentType: document_type,
          phoneNumber: phone_number
        }
      )
    end

    def payout_methods(counterparty_id:)
      post("/api/counterparties/#{counterparty_id}/payout-methods/search", {})
    end

    private

    def format_address(address)
      {
        addressLine1: address[:line1],
        addressLine2: address[:line2],
        city: address[:city],
        stateOrProvince: address[:state],
        postalCode: address[:postal_code],
        country: address[:country]
      }.compact
    end
  end
end
