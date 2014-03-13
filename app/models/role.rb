class Role < ActiveRecord::Base
  
  before_create :set_default_values
  
  validates_presence_of :category, :limit
  
  has_many :users
  
  def set_default_values
    self.limit ||= 15
  end
  
end
