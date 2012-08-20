class Collection < ActiveRecord::Base
  has_and_belongs_to_many :fabrics, :uniq => true
  belongs_to :user
  
  attr_accessible :name, :user, :fabrics
  validates_presence_of :name
  
  def destroy_all_fabrics
    self.fabrics.each { |f| f.destroy if f.collections.count == 1 }
  end
  
  def filter_by_tags(params)
    # Tag search
    #  - By default all tags from same type will be OR'd
    #  - By default all tags from different type will be AND'ed
    
    result = [];
    count = 0;
    tag_type_list = Tag.get_tagtype_list
    params.each_pair do |key, value|
      if tag_type_list.include?(key)
        if count == 0
          result = fabrics.joins(:tags).where('tags.name' => value)
        else
          result = result & fabrics.joins(:tags).where('tags.name' => value)
        end
          count+=1
      end
    end
    result
  end
    
  
end
