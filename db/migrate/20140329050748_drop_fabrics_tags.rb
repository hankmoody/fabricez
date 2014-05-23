class DropFabricsTags < ActiveRecord::Migration
  def change
    drop_table :fabrics_tags
  end
end
