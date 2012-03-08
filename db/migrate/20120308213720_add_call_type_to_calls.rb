class AddCallTypeToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :call_type, :string
    add_column :calls, :direction, :string
  end
end
