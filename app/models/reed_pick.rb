class ReedPick < ActiveRecord::Base
  belongs_to :fabric
  
  validates_presence_of :reed
  validates_presence_of :pick
  
  validates_format_of :full_reed_pick, :with => /\A\s*(\d+)\s*\/\s*(\d+)\s*\z/, :allow_blank => true,
                      :message => "Invalid! Eg: 20/30"
  
  def full_reed_pick
    "#{reed}/#{pick}" unless (reed.nil? || pick.nil?)
  end
  
  def full_reed_pick=(str)
    result = ReedPick.parse_string (str)
    self.reed = result[:reed]
    self.pick = result[:pick]
  end

  def self.parse_string (str)
    if str =~ /\A\s*(\d+)\s*\/\s*(\d+)\s*\z/  # a/b
      return { reed: $1.to_i, pick: $2.to_i }
    else
      return {}
    end
  end

end
