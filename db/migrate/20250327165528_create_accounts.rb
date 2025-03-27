class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :account_type
      t.string :identifier
      t.string :display_name
      t.string :accountable_type
      t.timestamps
    end
  end
end
