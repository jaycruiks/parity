require "administrate/base_dashboard"

class MerchantSettingDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    mural_account_id: Field::String,
    deposit_wallet_address: Field::String,
    mural_counterparty_id: Field::String,
    mural_payout_method_id: Field::String,
    bank_name: Field::String,
    bank_id: Field::String,
    bank_account_number: Field::String,
    account_type: Field::Select.with_options(
      collection: MerchantSetting::ACCOUNT_TYPES
    ),
    document_number: Field::String,
    document_type: Field::Select.with_options(
      collection: MerchantSetting::DOCUMENT_TYPES
    ),
    phone_number: Field::String,
    auto_convert_enabled: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    mural_account_id
    deposit_wallet_address
    auto_convert_enabled
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    mural_account_id
    deposit_wallet_address
    mural_counterparty_id
    mural_payout_method_id
    bank_name
    bank_id
    bank_account_number
    account_type
    document_number
    document_type
    phone_number
    auto_convert_enabled
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    mural_account_id
    deposit_wallet_address
    mural_counterparty_id
    mural_payout_method_id
    bank_name
    bank_id
    bank_account_number
    account_type
    document_number
    document_type
    phone_number
    auto_convert_enabled
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(merchant_setting)
    "Merchant Settings"
  end
end
