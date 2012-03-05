class AddCropToFabric < ActiveRecord::Migration
  def change
      add_column :fabrics, :crop_x, :integer, :default => 0
      add_column :fabrics, :crop_y, :integer, :default => 0
      add_column :fabrics, :crop_w, :integer, :default => 600
      add_column :fabrics, :crop_h, :integer, :default => 400
  end
end
