class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_one :withdrawal, dependent: :destroy

  enum :status, {
    pending: "pending",
    payment_requested: "payment_requested",
    paid: "paid",
    converting: "converting",
    withdrawn: "withdrawn",
    failed: "failed"
  }, default: :pending

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true
end
