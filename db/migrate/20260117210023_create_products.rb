class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.integer :price_cents
      t.integer :inventory_count, default: 0
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
