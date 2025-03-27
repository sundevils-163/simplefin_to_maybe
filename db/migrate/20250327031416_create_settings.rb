class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings, id: :uuid do |t|
      t.string :key
      t.text :value

      t.timestamps
    end

    # default values
    Setting.insert_all([
      { key: "simplefin_username", value: nil },
      { key: "simplefin_password", value: nil },
      { key: "maybe_postgres_host", value: nil },
      { key: "maybe_postgres_port", value: nil },
      { key: "maybe_postgres_db", value: nil },
      { key: "maybe_postgres_user", value: nil },
      { key: "maybe_postgres_password", value: nil },
      { key: "lookback_days", value: 30 },
      { key: "synchronization_schedule", value: '0 5,23 * * *' }
    ])
  end
end
