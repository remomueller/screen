class AddTaskTrackerScreenTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :task_tracker_screen_token, :string
    add_index :users, :task_tracker_screen_token, unique: true
  end
end
