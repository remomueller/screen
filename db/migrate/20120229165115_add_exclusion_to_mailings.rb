class AddExclusionToMailings < ActiveRecord::Migration
  def change
    add_column :mailings, :exclusion, :string
  end
end
