# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_18_010625) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "merchant_settings", force: :cascade do |t|
    t.string "mural_account_id"
    t.string "deposit_wallet_address"
    t.string "mural_counterparty_id"
    t.string "mural_payout_method_id"
    t.string "bank_name"
    t.string "bank_id"
    t.string "bank_account_number"
    t.string "account_type"
    t.string "document_number"
    t.string "document_type"
    t.string "phone_number"
    t.boolean "auto_convert_enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.integer "price_cents"
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "mural_payment_id"
    t.text "shipping_address"
    t.string "status", default: "pending"
    t.integer "total_cents"
    t.datetime "updated_at", null: false
    t.decimal "usdc_amount", precision: 18, scale: 6
    t.decimal "deposit_amount_usdc", precision: 18, scale: 6
    t.string "deposit_wallet_address"
    t.string "mural_account_id"
    t.index ["deposit_amount_usdc", "status"], name: "index_orders_on_deposit_amount_usdc_and_status"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "mural_transaction_id"
    t.decimal "amount_usdc", precision: 18, scale: 6
    t.string "status", default: "pending"
    t.string "blockchain"
    t.string "tx_hash"
    t.datetime "detected_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mural_transaction_id"], name: "index_payments_on_mural_transaction_id", unique: true
    t.index ["order_id", "status"], name: "index_payments_on_order_id_and_status"
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "inventory_count", default: 0
    t.string "name"
    t.integer "price_cents"
    t.datetime "updated_at", null: false
  end

  create_table "withdrawals", force: :cascade do |t|
    t.decimal "amount_cop", precision: 18, scale: 2
    t.text "bank_account_info"
    t.datetime "created_at", null: false
    t.string "mural_transfer_id"
    t.bigint "order_id", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.string "mural_payout_id"
    t.decimal "usdc_amount", precision: 18, scale: 6
    t.decimal "exchange_rate", precision: 18, scale: 6
    t.text "error_message"
    t.index ["mural_payout_id"], name: "index_withdrawals_on_mural_payout_id", unique: true
    t.index ["order_id"], name: "index_withdrawals_on_order_id"
  end

  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "payments", "orders"
  add_foreign_key "withdrawals", "orders"
end
