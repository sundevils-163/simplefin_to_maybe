class CreateLinkages < ActiveRecord::Migration[7.1]
  def change
    create_table :linkages, id: :uuid do |t|
      t.string :simplefin_account_id
      t.uuid :simplefin_id_sanitized
      t.uuid :maybe_account_id
      t.datetime :last_sync
      t.string :last_balance_epoch
      t.timestamps
    end
  end
end
