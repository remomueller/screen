class AddTtTemplateIdAndTtGroupIdToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :tt_template_id, :integer
    add_column :calls, :tt_group_id, :integer
  end
end
