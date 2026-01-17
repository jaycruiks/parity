FactoryBot.define do
  factory :withdrawal do
    order { nil }
    mural_transfer_id { "MyString" }
    amount_cop { "9.99" }
    status { "MyString" }
    bank_account_info { "MyText" }
  end
end
