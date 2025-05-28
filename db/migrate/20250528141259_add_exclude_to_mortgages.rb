class AddExcludeToMortgages < ActiveRecord::Migration[7.1]
  def change
    add_column :mortgages, :exclude, :boolean, default: false
  end
end
