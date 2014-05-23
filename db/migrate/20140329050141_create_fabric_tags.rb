class CreateFabricTags < ActiveRecord::Migration
  def change
    create_table :fabric_tags do |t|
      t.belongs_to :fabric
      t.belongs_to :tag
      t.timestamps    
    end
  end
end
