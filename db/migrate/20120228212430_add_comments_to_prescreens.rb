class AddCommentsToPrescreens < ActiveRecord::Migration
  def change
    add_column :prescreens, :comments, :text
  end
end
