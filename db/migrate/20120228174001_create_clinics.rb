class CreateClinics < ActiveRecord::Migration
  def change
    create_table :clinics do |t|
      t.string :name
      t.string :status
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
