class AddExclusionToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :exclusion, :string
  end
end
