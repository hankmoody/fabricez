class Color < ActiveRecord::Base
  
  belongs_to :fabric
  
  # Accessor
  attr_reader :hexvalue, :ciel_L, :ciel_a, :ciel_b   
  
  # Accessibility
  attr_accessible :red, :green, :blue, :hexvalue, :ciel_L, :ciel_a, :ciel_b 
  
  def hexvalue
    "\##{red.to_s(16)}#{green.to_s(16)}#{blue.to_s(16)}"
  end
  
  # Validations
  validates_numericality_of :red, :less_than_or_equal_to => 255, :greater_than_or_equal_to => 0
  validates_numericality_of :green, :less_than_or_equal_to => 255, :greater_than_or_equal_to => 0
  validates_numericality_of :blue, :less_than_or_equal_to => 255, :greater_than_or_equal_to => 0
  
  before_save :compute_Lab
  
  def compute_Lab
    lab = Color.get_Lab_from_RGB(self.red, self.green, self.blue)
    self.ciel_L = lab[:L]
    self.ciel_a = lab[:a]
    self.ciel_b = lab[:b]
    return true
  end
  

  class << self
    def get_Lab_from_RGB (red, green, blue)
      xyz = get_XYZ_from_RGB(red, green, blue)
      x = xyz[:X]/95.047
      y = xyz[:Y]/100.0
      z = xyz[:Z]/108.883
      
      x = (x > 0.008856) ? x ** (1/3.0) : (7.787 * x) + (16/116.0)
      y = (y > 0.008856) ? y ** (1/3.0) : (7.787 * y) + (16/116.0)
      z = (z > 0.008856) ? z ** (1/3.0) : (7.787 * z) + (16/116.0)
      
      lab = {}
      lab[:L] = ( 116.0 * y ) - 16.0
      lab[:a] = 500.0 * (x - y)
      lab[:b] = 200.0 * (y - z)
      return lab
    end
    
    def get_XYZ_from_RGB (red, green, blue)
      r = red / 255.0
      g = green / 255.0
      b = blue / 255.0
      
      r = (r > 0.04045) ? ((r+0.055)/1.055)**2.4 : r/12.92
      g = (g > 0.04045) ? ((g+0.055)/1.055)**2.4 : g/12.92
      b = (b > 0.04045) ? ((b+0.055)/1.055)**2.4 : b/12.92
      
      r = r*100.0
      g = g*100.0
      b = b*100.0
      
      xyz = {}
      xyz[:X] = r * 0.4124 + g * 0.3576 + b * 0.1805
      xyz[:Y] = r * 0.2126 + g * 0.7152 + b * 0.0722
      xyz[:Z] = r * 0.0193 + g * 0.1192 + b * 0.9505
      return xyz
    end
  end
  
end
