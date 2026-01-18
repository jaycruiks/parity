# == Schema Information
#
# Table name: orders
#
#  id                     :bigint           not null, primary key
#  deposit_amount_usdc    :decimal(18, 6)
#  deposit_wallet_address :string
#  email                  :string
#  shipping_address       :text
#  status                 :string           default("pending")
#  total_cents            :integer
#  usdc_amount            :decimal(18, 6)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  mural_account_id       :string
#  mural_payment_id       :string
#
# Indexes
#
#  index_orders_on_deposit_amount_usdc_and_status  (deposit_amount_usdc,status)
#
class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy
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

  before_create :generate_unique_deposit_amount
  before_create :assign_wallet_address

  scope :awaiting_payment, -> { where(status: :payment_requested) }

  def confirmed_payment
    payments.confirmed.first
  end

  private

  def generate_unique_deposit_amount
    return if deposit_amount_usdc.present?

    base_amount = total_cents / 100.0

    loop do
      random_suffix = rand(1..9999) / 10000.0
      candidate = (base_amount + random_suffix).round(4)

      unless Order.awaiting_payment
                  .where(deposit_amount_usdc: candidate)
                  .where("created_at > ?", 24.hours.ago)
                  .exists?
        self.deposit_amount_usdc = candidate
        break
      end
    end
  end

  def assign_wallet_address
    return if deposit_wallet_address.present?

    settings = MerchantSetting.current
    self.deposit_wallet_address = settings.deposit_wallet_address
    self.mural_account_id = settings.mural_account_id
  end
end
