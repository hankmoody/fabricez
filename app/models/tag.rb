class Tag < ActiveRecord::Base
  
  has_and_belongs_to_many :fabrics
  
  # Validations
  validates_presence_of :name
  validates_presence_of :tagtype
  validates_length_of :name, :tagtype, :maximum => 20
  validates_uniqueness_of :name, :case_sensitive => false

  class << self
    
    def get_name_list (tag_type)
      tag_array = get_names(tag_type)
      tag_array.join(", ") unless tag_array.empty?
    end
    
    def get_names (tag_type = nil)
      result = Tag.select("distinct name")
      result = result.where(tagtype: tag_type) unless tag_type.nil?
      result = result.map{ |t| t.name }
    end
    
    def get_tagtype_list
      Tag.select("distinct tagtype").map{|t| t.tagtype}
    end
  end

end
