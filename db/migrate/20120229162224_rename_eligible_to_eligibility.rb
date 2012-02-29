class RenameEligibleToEligibility < ActiveRecord::Migration
  def change
    rename_column :mailings, :eligible, :eligibility
    rename_column :calls, :eligible, :eligibility
  end
end
