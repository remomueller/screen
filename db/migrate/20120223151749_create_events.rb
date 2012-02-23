class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :patient_id
      t.string :class_name
      t.integer :class_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
