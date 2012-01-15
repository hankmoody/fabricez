class CreateReedPicks < ActiveRecord::Migration
  def change
    create_table :reed_picks do |t|
      t.integer :reed
      t.integer :pick
      t.integer :fabric_id
      t.timestamps
    end
  end
end
