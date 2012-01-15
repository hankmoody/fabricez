class Fabric < ActiveRecord::Base
  
  has_and_belongs_to_many :collections
  has_one :reed_pick, dependent: :destroy
  has_one :yarn_count, dependent: :destroy
  has_many :colors, dependent: :destroy
  
  attr_accessible :code, :width, :price, :quantity, :published, :processed,
                  :attachment, :reed_pick, :yarn_count, :colors
  
end
