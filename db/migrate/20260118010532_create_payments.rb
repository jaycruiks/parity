class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :mural_transaction_id
      t.decimal :amount_usdc, precision: 18, scale: 6
      t.string :status, default: "pending"
      t.string :blockchain
      t.string :tx_hash
      t.datetime :detected_at
      t.datetime :confirmed_at
      t.timestamps
    end

    add_index :payments, :mural_transaction_id, unique: true
    add_index :payments, [:order_id, :status]
  end
end
