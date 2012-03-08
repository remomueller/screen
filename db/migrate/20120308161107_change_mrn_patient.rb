class ChangeMrnPatient < ActiveRecord::Migration
  def up
    change_column :patients, :mrn, :string, default: '', null: false
  end

  def down
    change_column :patients, :mrn, :string, default: nil, null: true
  end
end
