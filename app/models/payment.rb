# == Schema Information
#
# Table name: payments
#
#  id                   :bigint           not null, primary key
#  amount_usdc          :decimal(18, 6)
#  blockchain           :string
#  confirmed_at         :datetime
#  detected_at          :datetime
#  status               :string           default("pending")
#  tx_hash              :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  mural_transaction_id :string
#  order_id             :bigint           not null
#
# Indexes
#
#  index_payments_on_mural_transaction_id  (mural_transaction_id) UNIQUE
#  index_payments_on_order_id              (order_id)
#  index_payments_on_order_id_and_status   (order_id,status)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
class Payment < ApplicationRecord
  belongs_to :order

  enum :status, {
    pending: "pending",
    detected: "detected",
    confirmed: "confirmed",
    failed: "failed"
  }, default: :pending

  validates :status, presence: true

  scope :unmatched, -> { where(order_id: nil) }
  scope :confirmed, -> { where(status: "confirmed") }

  def mark_detected!
    update!(status: :detected, detected_at: Time.current)
  end

  def mark_confirmed!
    update!(status: :confirmed, confirmed_at: Time.current)
    order.paid! if order.payment_requested?
  end
end
