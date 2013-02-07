class AddEmailToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :email, :string
  end
end
