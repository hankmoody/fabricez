class Color < ActiveRecord::Base
  
  belongs_to :fabric
  
  # Accessor
  attr_reader :hexvalue, :ciel_L, :ciel_a, :ciel_b   
  
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
    
    def compute_delta_e94 (lab1, lab2)
      # http://en.wikipedia.org/wiki/Color_difference#cite_note-7
      
      # lab1 is the reference color
      # lab2 will be compared to see if its close to lab1
      # This function is quasimetric (not symmetrical so a 
      #    call with lab1,lab2 is not equal to lab2, lab1)
      wht_h = 1.0
      wht_c = 1.0
      wht_l = 2.0
      
      xC1 = Math.sqrt( ( lab1[:a] ** 2 ) + ( lab1[:b] ** 2 ) )
      xC2 = Math.sqrt( ( lab2[:a] ** 2 ) + ( lab2[:b] ** 2 ) )
      xDL = (lab2[:L] - lab1[:L]).abs
      xDC = (xC2 - xC1).abs
      xDE = Math.sqrt( (lab1[:L] - lab2[:L])**2 +
                       (lab1[:a] - lab2[:a])**2 +
                       (lab1[:b] - lab2[:b])**2  )
      
      #puts "#{xC1}, #{xC2}, #{xDL}, #{xDC}, #{xDE} --- "                 
      if ( Math.sqrt( xDE ) > ( Math.sqrt( xDL.abs ) + Math.sqrt( xDC.abs ) ) )
         xDH = Math.sqrt( ( xDE * xDE ) - ( xDL * xDL ) - ( xDC * xDC ) )
      else 
         xDH = 0
      end
      
      #puts "#{xDH} --- "
      
      xSC = 1 + ( 0.048 * xC1 )
      xSH = 1 + ( 0.014 * xC1 )
      xDL /= wht_l
      xDC /= wht_c * xSC
      xDH /= wht_h * xSH
      #puts "#{xSC}, #{xSH}, #{xDL}, #{xDC}, #{xDH} --- "
      del_e94 = Math.sqrt( xDL ** 2 + xDC ** 2 + xDH ** 2 )
      return del_e94
    end    
    
    def extract_color_information (attachment)
      
      image_file = attachment.to_file(:thumb)
      begin      
        puts "Starting color extraction from #{image_file.path}\n"
        cmd_to_run = "convert #{image_file.path} -resize 100x100^ +dither -colors 30 -depth 16 -format %c histogram:info:-"
        result = `#{cmd_to_run}`
        #puts "The result of convert command is: #{result}\n"
      ensure
        # Delete the temporary file when done
        image_file.close
        image_file.unlink
      end
      
      # Parse the result to create an array of colors
      # first separate them into lines
      total_pixel_count = 100*100
      image_histogram = []
      lines = result.split("\n")
      lines.each do |line|
        color_info = {}
        # Split by spaces
        segments = line.split(" ");
        if (segments[0] =~ /(\d+):/)
          color_info[:count] = $1.to_i
          color_info[:coverage] = (color_info[:count]*100)/total_pixel_count
          #puts " Coverage is : #{color_info[:coverage]}\n"
        end
        rgb_codes = segments[3]
        if (rgb_codes =~ /rgb\((\d*\.?\d+)%,(\d*\.?\d+)%,(\d*\.?\d+)%\)/) # IM outputs colors as percentages in some versions
          color_info[:red] = ($1.to_f * 2.55).to_i
          color_info[:green] = ($2.to_f * 2.55).to_i
          color_info[:blue] = ($3.to_f * 2.55).to_i
          color_info[:hexstring] = "\##{color_info[:red].to_s(16)}#{color_info[:green].to_s(16)}#{color_info[:blue].to_s(16)}"
          image_histogram << color_info
        elsif (rgb_codes =~ /rgb\((\d+),(\d+),(\d+)\)/)
          color_info[:red] = $1.to_i
          color_info[:green] = $2.to_i
          color_info[:blue] = $3.to_i
          color_info[:hexstring] = "\##{color_info[:red].to_s(16)}#{color_info[:green].to_s(16)}#{color_info[:blue].to_s(16)}"
          image_histogram << color_info        
        end
      end
      
      # Sort in descending order
      image_histogram = image_histogram.sort{ |image_histogram, color| color[:count] <=> image_histogram[:count]}
      
      # We have our histogram. Time for some fuzz testing
      selected_colors = []
      image_histogram.each do |color|
        #logger.debug "#{color[:red]}, #{color[:green]}, #{color[:blue]}\n"
        if selected_colors.empty?
          selected_colors << color
        else
          color_far_apart = true
          selected_colors.each do |sel_color|
            fuzz_cmd = "compare -dissimilarity-threshold 1 -fuzz 6% -metric AE xc:#{color[:hexstring]} xc:#{sel_color[:hexstring]} null:"
            result = `#{fuzz_cmd} 2>&1`
            result = result.to_i
            #logger.debug "Result is #{result}\n"
            if (result.to_i == 0)
              #logger.debug "#{col_string} is close to #{sel_col_string}\n"
              color_far_apart = false
              break
            else
              #logger.debug "#{col_string} is far apart from #{sel_col_string}\n"
            end
          end
          selected_colors << color if color_far_apart
          break if selected_colors.length == 10
        end
      end

      selected_colors.each do |color|
        color_lab = get_Lab_from_RGB(color[:red],
                                     color[:green],
                                     color[:blue])
        selected_colors.each do |col|
          if color != col
            col_lab = get_Lab_from_RGB(col[:red],
                                       col[:green],
                                       col[:blue])
            del_e = Color.compute_delta_e94(color_lab, col_lab)      
            selected_colors.delete(col) if del_e < 6    
          end
        end
      end
      
      return selected_colors
    end
    
    def get_RGB_from_hex (hex_value)
      rgb = {}
      if (hex_value =~ /#([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})/)
        rgb[:red] = $1.to_i(16)
        rgb[:green] = $2.to_i(16)
        rgb[:blue] = $3.to_i(16)
      end
      rgb
    end
    
    def filter (hex_value, tolerance=1)
      tolerance = 1 if tolerance.nil?
      rgb = get_RGB_from_hex(hex_value)
      lab = get_Lab_from_RGB(rgb[:red], rgb[:green], rgb[:blue])
      selected_colors = []
      Color.all.each do |col|
        lab_col = {:L => col[:ciel_L], :a => col[:ciel_a], :b => col[:ciel_b]}
        del_e = compute_delta_e94(lab, lab_col)
        puts "delta e94 is #{del_e}\n"
        if del_e <= tolerance
          selected_colors << {:color => col, :del_e => del_e}
        end
      end
      return selected_colors.sort_by {|sc| sc[:del_e]}.collect {|sc| sc[:color]} unless selected_colors.empty?
      return [] 
    end
    
  end
  
end
