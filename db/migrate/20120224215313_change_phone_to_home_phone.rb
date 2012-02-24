class ChangePhoneToHomePhone < ActiveRecord::Migration
  def change
    rename_column :patients, :phone, :phone_home
    rename_column :patients, :address, :address1
    add_column :patients, :city, :string
    add_column :patients, :state, :string
    add_column :patients, :zip, :string
    add_column :patients, :phone_alt, :string
    add_column :patients, :ess, :integer
    add_column :patients, :berlin, :integer
  end
end
