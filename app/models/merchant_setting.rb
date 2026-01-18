# == Schema Information
#
# Table name: merchant_settings
#
#  id                     :bigint           not null, primary key
#  account_type           :string
#  auto_convert_enabled   :boolean          default(TRUE)
#  bank_account_number    :string
#  bank_name              :string
#  deposit_wallet_address :string
#  document_number        :string
#  document_type          :string
#  phone_number           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  bank_id                :string
#  mural_account_id       :string
#  mural_counterparty_id  :string
#  mural_payout_method_id :string
#
class MerchantSetting < ApplicationRecord
  validates :mural_account_id, presence: true, on: :update
  validates :deposit_wallet_address, presence: true, on: :update

  ACCOUNT_TYPES = %w[CHECKING SAVINGS].freeze
  DOCUMENT_TYPES = %w[NATIONAL_ID PASSPORT RESIDENT_ID RUC TAX_ID].freeze

  validates :account_type, inclusion: { in: ACCOUNT_TYPES }, allow_blank: true
  validates :document_type, inclusion: { in: DOCUMENT_TYPES }, allow_blank: true

  def self.current
    first_or_create!
  end

  def configured?
    mural_account_id.present? && deposit_wallet_address.present?
  end

  def payout_configured?
    mural_counterparty_id.present? && mural_payout_method_id.present?
  end

  def bank_details_complete?
    bank_id.present? &&
      bank_account_number.present? &&
      account_type.present? &&
      document_number.present? &&
      document_type.present? &&
      phone_number.present?
  end
end
