class CollectionFabric < ActiveRecord::Migration
  def up
    create_table :collections_fabrics, :id => false do |t|
      t.references :collection, :fabric
    end
  end

  def down
  end
end
