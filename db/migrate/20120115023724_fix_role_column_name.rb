class FixRoleColumnName < ActiveRecord::Migration
  def change
    rename_column :roles, :type, :category
  end
end
