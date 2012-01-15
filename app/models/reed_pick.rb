class ReedPick < ActiveRecord::Base
  belongs_to :fabric
  
  # Validations
  validates_presence_of :reed
  validates_presence_of :pick
  
  # Virtual Attributes
  def full_reed_pick
    # Convention says Reed / Pick
    "#{reed}/#{pick}"
  end
  
  def full_reed_pick=(reedpick)
    # argument must be in a/b form
    if reedpick =~ /^\s*(\d+)\s*\/\s*(\d+)\s*$/
      self.reed = $1
      self.pick = $2
    else
      return nil
    end
    
    # reed_pick_array = reedpick.split('/').collect {|s| s.strip}
    # yarn_count_array = full_yarn_count.split("x").collect { |s| s.strip }
    # self.warp_count = yarn_count_array[0]
    # self.weft_count = yarn_count_array[1]
    
  end

  # Accessibility
  attr_accessible :full_reed_pick, :reed, :pick

end
