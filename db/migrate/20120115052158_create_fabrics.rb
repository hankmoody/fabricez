class CreateFabrics < ActiveRecord::Migration
  def change  
    create_table :fabrics do |t|
      t.string :code
      t.integer :width
      t.decimal :price, :precision => 9, :scale => 2
      t.decimal :quantity, :precision => 9, :scale => 2
      t.has_attached_file :attachment
      t.timestamps
    end
  end
end
