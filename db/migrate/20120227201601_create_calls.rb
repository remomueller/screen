class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.integer :patient_id
      t.string :response
      t.datetime :call_time
      t.integer :berlin
      t.integer :ess
      t.string :eligible
      t.text :comments
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
