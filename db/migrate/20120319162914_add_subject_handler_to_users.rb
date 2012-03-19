class AddSubjectHandlerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subject_handler, :boolean, null: false, default: false
  end
end
