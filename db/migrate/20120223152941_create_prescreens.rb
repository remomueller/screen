class CreatePrescreens < ActiveRecord::Migration
  def change
    create_table :prescreens do |t|
      t.integer :patient_id
      t.integer :clinic_id
      t.integer :doctor_id
      t.datetime :visit_at
      t.integer :visit_duration, null: false, default: 0
      t.string :visit_units
      t.string :eligibility
      t.string :exclusion
      t.string :old_risk_factors
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
