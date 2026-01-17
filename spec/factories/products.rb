FactoryBot.define do
  factory :product do
    name { "MyString" }
    description { "MyText" }
    price_cents { 1 }
    inventory_count { 1 }
    active { false }
  end
end
