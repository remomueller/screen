class ChangeAssessmentDateToAdministrationDate < ActiveRecord::Migration
  def change
    rename_column :evaluations, :assessment_date, :administration_date
    rename_column :evaluations, :assessment_type, :administration_type
  end
end
