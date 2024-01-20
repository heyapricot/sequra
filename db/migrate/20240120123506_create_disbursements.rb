class CreateDisbursements < ActiveRecord::Migration[7.1]
  def change
    create_table :disbursements, id: :uuid do |t|
      t.references :merchant, null: false, foreign_key: true, type: :uuid
      t.decimal :merchant_disbursement_total, precision: 8, scale: 2, null: false
      t.decimal :orders_fee_sum, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
