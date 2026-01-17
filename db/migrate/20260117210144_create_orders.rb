class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :email
      t.text :shipping_address
      t.string :status, default: "pending"
      t.integer :total_cents
      t.decimal :usdc_amount, precision: 18, scale: 6
      t.string :mural_payment_id

      t.timestamps
    end
  end
end
