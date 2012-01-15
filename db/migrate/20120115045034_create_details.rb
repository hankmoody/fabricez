class CreateDetails < ActiveRecord::Migration
  def change
    create_table :details do |t|
      t.string :first_name
      t.string :last_name
      t.string :company_name
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :country
      t.string :state
      t.string :city
      t.string :zip
      t.string :phone
      t.integer :user_id
      t.timestamps
    end
  end
end
