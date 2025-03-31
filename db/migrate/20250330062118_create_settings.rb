class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings, id: :uuid do |t|
      t.string :display_name
      t.string :key, null: false  # Ensure key is not null
      t.text :value
      t.timestamps
    end

    # Add unique index on the key column to ensure uniqueness
    add_index :settings, :key, unique: true
  end
end
