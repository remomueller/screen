class AddSubjectCodeToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :subject_code, :string, default: '', null: false
    add_column :patients, :name_code, :string
  end
end
