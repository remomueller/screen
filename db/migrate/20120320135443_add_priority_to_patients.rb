class AddPriorityToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :priority, :integer, null: false, default: 0
    add_column :patients, :priority_message, :string, null: false, default: ''
  end
end
