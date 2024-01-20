class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.references :disbursement, null: true, foreign_key: true, type: :uuid
      t.references :merchant, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
