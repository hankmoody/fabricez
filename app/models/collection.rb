class Collection < ActiveRecord::Base
  has_and_belongs_to_many :fabrics
  belongs_to :user
  
  attr_accessible :name
  validates_presence_of :name
  
  def destroy_all_fabrics
    self.fabrics.each { |f| f.destroy if f.collections.count == 1 }
  end
  
end
