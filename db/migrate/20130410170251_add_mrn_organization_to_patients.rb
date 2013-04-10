class AddMrnOrganizationToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :mrn_organization, :string
  end
end
