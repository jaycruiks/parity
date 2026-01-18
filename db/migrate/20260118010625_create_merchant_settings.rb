class CreateMerchantSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_settings do |t|
      # Mural account for receiving deposits
      t.string :mural_account_id
      t.string :deposit_wallet_address

      # Mural counterparty and payout method for COP withdrawals
      t.string :mural_counterparty_id
      t.string :mural_payout_method_id

      # COP bank account details
      t.string :bank_name
      t.string :bank_id
      t.string :bank_account_number
      t.string :account_type
      t.string :document_number
      t.string :document_type
      t.string :phone_number

      # Configuration
      t.boolean :auto_convert_enabled, default: true

      t.timestamps
    end
  end
end
