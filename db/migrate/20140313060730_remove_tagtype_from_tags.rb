class RemoveTagtypeFromTags < ActiveRecord::Migration
  def change
    remove_column :tags, :tagtype, :string
  end
end
