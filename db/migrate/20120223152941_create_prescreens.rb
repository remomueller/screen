class CreatePrescreens < ActiveRecord::Migration
  def change
    create_table :prescreens do |t|
      t.integer :patient_id
      t.string :clinic
      t.string :cardiologist
      t.datetime :visit_at
      t.integer :visit_duration
      t.string :visit_units
      t.string :eligibility
      t.string :exclusion
      t.string :risk_factors
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
