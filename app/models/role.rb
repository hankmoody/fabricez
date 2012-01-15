class Role < ActiveRecord::Base
  
  attr_accessible :category, :limit
  
  validates_presence_of :category, :limit
  
  has_many :users
  
end
