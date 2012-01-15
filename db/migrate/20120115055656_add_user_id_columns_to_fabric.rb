class AddUserIdColumnsToFabric < ActiveRecord::Migration
  def change
    add_column :fabrics, :user_id, :integer
  end
end
