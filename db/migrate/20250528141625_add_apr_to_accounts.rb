class AddAprToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :apr, :decimal, precision: 10, scale: 4
  end
end
