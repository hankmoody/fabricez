class AddLogoToDetails < ActiveRecord::Migration
  def change
    add_column :details, :logo_file_name, :string
    add_column :details, :logo_content_type, :string
    add_column :details, :logo_file_size, :integer    
  end
end
