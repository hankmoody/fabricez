class YarnCount < ActiveRecord::Base
  belongs_to :fabric
  
  # Validations
  # validates_presence_of :warp_yarn_thickness
  # validates_presence_of :weft_yarn_thickness
  validates_count :full_count
  
  def full_count
    "#{warp_count} x #{weft_count}" unless (warp_yarn_thickness.nil? || weft_yarn_thickness.nil?)
  end
  
  def full_count=(full_yarn_count)
    result = YarnCount.parse(full_yarn_count)
    self.weft_ply_count = result[:weft_ply_count]
    self.weft_yarn_thickness = result[:weft_yarn_thickness]
    self.warp_ply_count = result[:warp_ply_count]
    self.warp_yarn_thickness = result[:warp_yarn_thickness]
  end

  class << self
    def parse (str)
      @result = Hash.new
      split_across_x (str) if validate (str)
      @result
    end

    private
      def validate (str)
        # TODO: Add regular expression validation instead
        ! str.nil? && ((str.include? ?x) || (str.include? ?X))
      end

      def split_across_x (str)
        result = str.strip.split('x')
        split_across_slash(result.first, 'warp')
        split_across_slash(result.last, 'weft')
      end

      def split_across_slash (str, prefix)
        result = normalize_and_split(str)
        if result.count == 1
          @result["#{prefix}_ply_count".to_sym] = 0
          @result["#{prefix}_yarn_thickness".to_sym] = result.first
        else
          @result["#{prefix}_ply_count".to_sym] = result.first
          @result["#{prefix}_yarn_thickness".to_sym] = result.last
        end
      end

      def normalize_and_split (str)
        str.strip.gsub(/s/, "").split('/').map {|s| s.strip.to_i }
      end
  end

  private
    def warp_count
      display_full_count(self.warp_ply_count, self.warp_yarn_thickness)
    end

    def weft_count
      display_full_count(self.weft_ply_count, self.weft_yarn_thickness)
    end

    def display_full_count (ply, thickness)
      if !ply.nil? && ply > 0
        "#{ply}/#{thickness}s"
      else
        "#{thickness}s"
      end
    end

end
