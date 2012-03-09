class AddIndicesToTables < ActiveRecord::Migration
  def change
    add_index :authentications, :user_id
    add_index :calls, :patient_id
    add_index :calls, :user_id
    add_index :choices, :user_id
    add_index :clinics, :user_id
    add_index :doctors, :user_id
    add_index :evaluations, :patient_id
    add_index :evaluations, :user_id
    add_index :events, :patient_id
    add_index :events, [:class_name, :class_id]
    add_index :mailings, :patient_id
    add_index :mailings, :doctor_id
    add_index :mailings, :user_id
    add_index :patients, :user_id
    add_index :prescreens, :patient_id
    add_index :prescreens, :clinic_id
    add_index :prescreens, :doctor_id
    add_index :prescreens, :user_id
    add_index :visits, :patient_id
    add_index :visits, :user_id
  end
end
