class CreateYarnCounts < ActiveRecord::Migration
  def change
    create_table :yarn_counts do |t|
      t.integer :warp_ply_count
      t.integer :weft_ply_count
      t.integer :warp_yarn_thickness
      t.integer :weft_yarn_thickness
      t.integer :fabric_id
      t.timestamps
    end
  end
end
