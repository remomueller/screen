class AddDoctorIdToMailing < ActiveRecord::Migration
  def change
    add_column :mailings, :doctor_id, :integer

  end
end
