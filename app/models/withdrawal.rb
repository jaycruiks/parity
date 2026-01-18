# == Schema Information
#
# Table name: withdrawals
#
#  id                :bigint           not null, primary key
#  amount_cop        :decimal(18, 2)
#  bank_account_info :text
#  error_message     :text
#  exchange_rate     :decimal(18, 6)
#  status            :string           default("pending")
#  usdc_amount       :decimal(18, 6)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  mural_payout_id   :string
#  mural_transfer_id :string
#  order_id          :bigint           not null
#
# Indexes
#
#  index_withdrawals_on_mural_payout_id  (mural_payout_id) UNIQUE
#  index_withdrawals_on_order_id         (order_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
class Withdrawal < ApplicationRecord
  belongs_to :order

  enum :status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }, default: :pending

  validates :status, presence: true
end
