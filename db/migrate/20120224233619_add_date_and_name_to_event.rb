class AddDateAndNameToEvent < ActiveRecord::Migration
  def change
    add_column :events, :event_time, :datetime
    add_column :events, :name, :string
  end
end
