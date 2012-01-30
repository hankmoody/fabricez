class ReedPick < ActiveRecord::Base
  belongs_to :fabric
  
  # Validations
  # validates_presence_of :reed
  # validates_presence_of :pick
  
  validates_format_of :full_reed_pick, :with => /^\s*(\d+)\s*\/\s*(\d+)\s*$/, :allow_blank => true,
                      :message => "Invalid! Eg: 20/30"
  
  # Virtual Attributes
  def full_reed_pick
    # Convention says Reed / Pick
    "#{reed}/#{pick}" unless (reed.nil? || pick.nil?)
  end
  
  def full_reed_pick=(reedpick)
    # argument must be in a/b form
    if reedpick =~ /^\s*(\d+)\s*\/\s*(\d+)\s*$/
      self.reed = $1
      self.pick = $2
    else
      return nil
    end
  end

  # Accessibility
  attr_accessible :full_reed_pick, :reed, :pick

end
