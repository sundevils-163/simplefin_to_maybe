class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :account_type
      t.string :identifier
      t.string :display_name
      t.string :accountable_type
      t.uuid :maybe_family_id
      t.string :currency
      t.timestamps
    end
    add_index :accounts, :identifier
  end
end
