class RenameStatusToCommentsForMailings < ActiveRecord::Migration
  def change
    rename_column :mailings, :status, :comments
  end
end
