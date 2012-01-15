class Detail < ActiveRecord::Base
  
  attr_accessible :first_name, :last_name, :company_name, :address1, :address2,
                  :address3, :country, :state, :city, :zip, :phone
  
  belongs_to :user
end
