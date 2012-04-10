class StringToIntegerForeignKey < ActiveRecord::Migration
  def up
    change_column :calls, :response, :integer
    change_column :calls, :participation, :integer
    change_column :calls, :exclusion, :integer
    change_column :calls, :call_type, :integer
    change_column :evaluations, :administration_type, :integer
    change_column :evaluations, :evaluation_type, :integer
    change_column :evaluations, :exclusion, :integer
    change_column :mailings, :participation, :integer
    change_column :mailings, :exclusion, :integer
    change_column :prescreens, :exclusion, :integer
    change_column :visits, :outcome, :integer
    change_column :visits, :visit_type, :integer
  end

  def down
    change_column :calls, :response, :string
    change_column :calls, :participation, :string
    change_column :calls, :exclusion, :string
    change_column :calls, :call_type, :string
    change_column :evaluations, :administration_type, :string
    change_column :evaluations, :evaluation_type, :string
    change_column :evaluations, :exclusion, :string
    change_column :mailings, :participation, :string
    change_column :mailings, :exclusion, :string
    change_column :prescreens, :exclusion, :string
    change_column :visits, :outcome, :string
    change_column :visits, :visit_type, :string
  end
end
