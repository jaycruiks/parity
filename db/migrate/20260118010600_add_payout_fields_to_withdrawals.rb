class AddPayoutFieldsToWithdrawals < ActiveRecord::Migration[8.0]
  def change
    add_column :withdrawals, :mural_payout_id, :string
    add_column :withdrawals, :usdc_amount, :decimal, precision: 18, scale: 6
    add_column :withdrawals, :exchange_rate, :decimal, precision: 18, scale: 6
    add_column :withdrawals, :error_message, :text

    add_index :withdrawals, :mural_payout_id, unique: true
  end
end
