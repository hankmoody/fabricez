class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :type
      t.integer :limit
      t.timestamps
    end
  end
end
