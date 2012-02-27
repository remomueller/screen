class CreateMailings < ActiveRecord::Migration
  def change
    create_table :mailings do |t|
      t.integer :patient_id
      t.date :sent_date
      t.date :response_date
      t.integer :berlin
      t.integer :ess
      t.string :eligible
      t.text :status
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
