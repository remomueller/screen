class AddParticipationToMailings < ActiveRecord::Migration
  def change
    add_column :mailings, :participation, :string
  end
end
