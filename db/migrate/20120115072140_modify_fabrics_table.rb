class ModifyFabricsTable < ActiveRecord::Migration
  def up
    add_column :fabrics, :published, :boolean, :default => false
    add_column :fabrics, :processed, :boolean, :default => false
    remove_column :fabrics, :user_id
  end

  def down
    add_column :fabrics, :user_id, :integer
    remove_column :fabrics, :processed
    remove_column :fabrics, :published
  end
end
