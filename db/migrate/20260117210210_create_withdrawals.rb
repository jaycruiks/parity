class CreateWithdrawals < ActiveRecord::Migration[8.1]
  def change
    create_table :withdrawals do |t|
      t.references :order, null: false, foreign_key: true
      t.string :mural_transfer_id
      t.decimal :amount_cop, precision: 18, scale: 2
      t.string :status, default: "pending"
      t.text :bank_account_info

      t.timestamps
    end
  end
end
