class AddMuralPayFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :deposit_amount_usdc, :decimal, precision: 18, scale: 6
    add_column :orders, :deposit_wallet_address, :string
    add_column :orders, :mural_account_id, :string

    add_index :orders, [:deposit_amount_usdc, :status]
  end
end
