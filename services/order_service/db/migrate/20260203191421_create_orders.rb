class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.integer :customer_id
      t.string :product_name
      t.integer :quantity
      t.decimal :price, null: false, precision: 7, scale: 2
      t.string :status

      t.timestamps
    end
    add_index :orders, :customer_id
  end
end
