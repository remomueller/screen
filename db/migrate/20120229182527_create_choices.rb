class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.string :category
      t.string :name
      t.text :description
      t.string :color, default: "#dddddd", null: false
      t.boolean :deleted, default: false, null: false

      t.timestamps
    end
  end
end
