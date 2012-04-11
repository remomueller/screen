class AddIncludedFieldsToChoices < ActiveRecord::Migration
  def change
    add_column :choices, :included_fields, :string, default: '', null: false
  end
end
