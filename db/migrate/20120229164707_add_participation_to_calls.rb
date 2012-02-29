class AddParticipationToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :participation, :string
  end
end
