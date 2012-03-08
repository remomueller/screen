class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.integer :patient_id
      t.string :visit_type
      t.date :visit_date
      t.string :outcome
      t.text :comments
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
