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
      result = tag_type.nil? ? all : where(tagtype: tag_type)
      result = result.sort_by { |t| -t.fabrics.count }.map{ |t| t.name }
    end
    
    def get_ordered_materials
      Tag.where(tagtype: 'material').order('name').map {|t| t.name}
    end
    
    def get_tagtype_list
      Tag.select("distinct tagtype").map{|t| t.tagtype}
    end
    
    def get_default_tagtype_list
      ["contents", "best_for", "weave", "pattern", "season", "material", "other"]
    end
  end

end
