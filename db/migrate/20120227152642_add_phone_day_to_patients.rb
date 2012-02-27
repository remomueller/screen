class AddPhoneDayToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :phone_day, :string

  end
end
