class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.integer :red
      t.integer :green
      t.integer :blue
      t.float :ciel_L
      t.float :ciel_a
      t.float :ciel_b
      t.integer :fabric_id
      t.timestamps
    end
  end
end
