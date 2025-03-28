class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings, id: :uuid do |t|
      t.string :display_name
      t.string :key
      t.text :value
      t.text :encrypted_value
      t.boolean :encrypted, default: false, null: false
      t.timestamps
    end

    # default values
    Setting.insert_all([
      { display_name: "SimpleFIN Username", key: "simplefin_username", value: nil, encrypted_value: nil, encrypted: true },
      { display_name: "SimpleFIN Password", key: "simplefin_password", value: nil, encrypted_value: nil, encrypted: true },
      { display_name: "Maybe PostgreSQL Host", key: "maybe_postgres_host", value: nil, encrypted_value: nil, encrypted: false },
      { display_name: "Maybe PostgreSQL Port", key: "maybe_postgres_port", value: nil, encrypted_value: nil, encrypted: false },
      { display_name: "Maybe PostgreSQL Database", key: "maybe_postgres_db", value: nil, encrypted_value: nil, encrypted: false },
      { display_name: "Maybe PostgreSQL User", key: "maybe_postgres_user", value: nil, encrypted_value: nil, encrypted: false },
      { display_name: "Maybe PostgreSQL Password", key: "maybe_postgres_password", value: nil, encrypted_value: nil, encrypted: true },
      { display_name: "Lookback Days", key: "lookback_days", value: nil, encrypted_value: nil, encrypted: false },
      { display_name: "Sync Schedule", key: "synchronization_schedule", value: nil, encrypted_value: nil, encrypted: false }
    ])
  end
end
