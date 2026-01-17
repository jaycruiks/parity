FactoryBot.define do
  factory :order do
    email { "MyString" }
    shipping_address { "MyText" }
    status { "MyString" }
    total_cents { 1 }
    usdc_amount { "9.99" }
    mural_payment_id { "MyString" }
  end
end
