class CreateMailings < ActiveRecord::Migration
  def change
    create_table :mailings do |t|
      t.date :sent_date
      t.date :received_date
      t.integer :berlin
      t.integer :ess
      t.string :eligible
      t.text :status

      t.timestamps
    end
  end
end
