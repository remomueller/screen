class AhiToFloat < ActiveRecord::Migration
  def up
    change_column :evaluations, :ahi, :decimal, precision: 8, scale: 2
  end

  def down
    change_column :evaluations, :ahi, :integer
  end
end
