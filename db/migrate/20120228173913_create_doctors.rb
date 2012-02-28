class CreateDoctors < ActiveRecord::Migration
  def change
    create_table :doctors do |t|
      t.string :name
      t.string :doctor_type
      t.string :status
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
