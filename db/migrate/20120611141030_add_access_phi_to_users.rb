class AddAccessPhiToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_phi, :boolean, default: false, null: false
  end
end
