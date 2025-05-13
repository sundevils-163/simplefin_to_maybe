class CreateMortgages < ActiveRecord::Migration[7.1]
  def change
    create_table :mortgages, id: :uuid do |t|
      t.uuid :maybe_account_id
      t.decimal :apr, precision: 10, scale: 4
      t.decimal :escrow_payment, precision: 10, scale: 2
      t.integer :day_of_month
      t.boolean :enabled, default: true, null: false
      t.timestamps
    end
  end
end
