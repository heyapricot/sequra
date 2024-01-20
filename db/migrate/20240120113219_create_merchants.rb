class CreateMerchants < ActiveRecord::Migration[7.1]
  def up
    create_enum :disbursement_rate, ["DAILY", "WEEKLY"]

    create_table :merchants, id: :uuid do |t|
      t.string :reference, null: false
      t.string :email, null: false
      t.date :live_on, null: false
      t.enum :disbursement_frequency, null: false, enum_type: :disbursement_rate
      t.decimal :minimum_monthly_fee, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end

  def down
    drop_table :merchants
    drop_enum :disbursement_rate
  end
end
