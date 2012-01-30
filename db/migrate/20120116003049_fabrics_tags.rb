class FabricsTags < ActiveRecord::Migration
  def change
    create_table :fabrics_tags, :id => false do |t|
      t.references :tag, :fabric
    end
  end
end
