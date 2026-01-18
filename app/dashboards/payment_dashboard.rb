require "administrate/base_dashboard"

class PaymentDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    order: Field::BelongsTo,
    mural_transaction_id: Field::String,
    amount_usdc: Field::String.with_options(searchable: false),
    status: Field::Select.with_options(
      searchable: false,
      collection: ->(field) { field.resource.class.statuses.keys }
    ),
    blockchain: Field::String,
    tx_hash: Field::String,
    detected_at: Field::DateTime,
    confirmed_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    order
    amount_usdc
    status
    confirmed_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    order
    mural_transaction_id
    amount_usdc
    status
    blockchain
    tx_hash
    detected_at
    confirmed_at
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    order
    mural_transaction_id
    amount_usdc
    status
    blockchain
    tx_hash
  ].freeze

  COLLECTION_FILTERS = {
    pending: ->(resources) { resources.where(status: "pending") },
    confirmed: ->(resources) { resources.where(status: "confirmed") }
  }.freeze

  def display_resource(payment)
    "Payment ##{payment.id}"
  end
end
