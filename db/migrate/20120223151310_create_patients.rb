class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.string :mrn
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :sex
      t.integer :age
      t.string :address
      t.string :encrypted_address
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
