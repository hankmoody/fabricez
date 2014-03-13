class YarnCount < ActiveRecord::Base
  belongs_to :fabric
  
  # Validations
  # validates_presence_of :warp_yarn_thickness
  # validates_presence_of :weft_yarn_thickness
  validates_count :full_count
  
  
  # Virtual Attributes
  def full_count
    # Convention says Warp x Weft
    "#{warp_count} x #{weft_count}" unless (warp_yarn_thickness.nil? || weft_yarn_thickness.nil?)
  end
  
  def full_count=(full_yarn_count)
    if ((!full_yarn_count.include? ?x) && (!full_yarn_count.include? ?X))
      return nil
    end
    # argument must be in a/b x c/ds form
    yarn_count_array = full_yarn_count.split("x").collect { |s| s.strip }
    self.warp_count = yarn_count_array[0]
    self.weft_count = yarn_count_array[1]
  end
  
  def weft_count
    # Example: 2/40s
    display_full_count(self.weft_ply_count, self.weft_yarn_thickness)
  end
  
  def weft_count=(we_count)
    count_hash = parse_count(we_count)
    #weft_count_array = we_count.split("/").collect {|yc| yc.strip.gsub(/s/, "").to_i }
    self.weft_ply_count = count_hash[:ply_count]
    self.weft_yarn_thickness = count_hash[:thickness]
  end
  
  def warp_count
    # Example: 2/40s
    display_full_count(self.warp_ply_count, self.warp_yarn_thickness)
  end
  
  def warp_count=(wa_count)
    count_hash = parse_count(wa_count)
    # warp_count_array = wa_count.split("/").collect {|yc| yc.strip.gsub(/s/, "").to_i }
    self.warp_ply_count = count_hash[:ply_count]
    self.warp_yarn_thickness = count_hash[:thickness]
  end
  
  private
  def parse_count (count)
    # This method parses counts in one of following formats
    #   - A/Bs
    #   - As
    #   - A
    count_hash = { :ply_count => 0, :thickness => 0}
    # First check for the presence of '/'
    if (count.include? ?/)
      count_array = count.split("/").collect {|yc| yc.strip.gsub(/s/, "").to_i }
      count_hash[:ply_count] = count_array[0];
      count_hash[:thickness] = count_array[1];
    else
      count_hash[:thickness] = count.strip.gsub(/s/, "").to_i
    end
    return count_hash
  end
  
  def display_full_count (ply, thickness)
    if (ply && ply > 0)
      "#{ply}/#{thickness}s"
    else
      "#{thickness}s"
    end
  end
  
end
