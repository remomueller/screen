class CreateChoicesPrescreens < ActiveRecord::Migration
  def change
    create_table :choices_prescreens, id: false do |t|
      t.integer :choice_id
      t.integer :prescreen_id
    end

    add_index :choices_prescreens, :choice_id
    add_index :choices_prescreens, :prescreen_id
  end
end
