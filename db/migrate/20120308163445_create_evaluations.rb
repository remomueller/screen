class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.integer :patient_id
      t.string :assessment_type
      t.string :evaluation_type
      t.string :source
      t.string :embletta_unit_number
      t.date :assessment_date
      t.date :expected_receipt_date
      t.date :receipt_date
      t.date :storage_date
      t.boolean :subject_notified, null: false, default: false
      t.date :reimbursement_form_date
      t.date :scored_date
      t.integer :ahi
      t.string :eligibility
      t.string :exclusion
      t.string :status
      t.text :comments
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
