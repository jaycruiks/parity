# == Schema Information
#
# Table name: orders
#
#  id               :bigint           not null, primary key
#  email            :string
#  shipping_address :text
#  status           :string           default("pending")
#  total_cents      :integer
#  usdc_amount      :decimal(18, 6)
#  mural_payment_id :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
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
