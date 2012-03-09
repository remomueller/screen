class AddUserToAllEvents < ActiveRecord::Migration
  def change
    add_column :calls, :user_id, :integer
    add_column :choices, :user_id, :integer
    add_column :clinics, :user_id, :integer
    add_column :doctors, :user_id, :integer
    add_column :evaluations, :user_id, :integer
    add_column :mailings, :user_id, :integer
    add_column :patients, :user_id, :integer
    add_column :prescreens, :user_id, :integer
    add_column :visits, :user_id, :integer
  end
end
