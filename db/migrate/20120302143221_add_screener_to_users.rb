class AddScreenerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :screener, :boolean, null: false, default: false
  end
end
