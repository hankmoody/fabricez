module Paperclip
  class Cropresize < Processor
    def initialize file, options = {}, attachment = nil
      @file = file
      @options = options
      @attachment = attachment
    end
    def make
      src = @file
      options = @options
      attachment = @attachment
      
      geometry_second = options[:geometry_second]
      if (geometry_second == nil)
        src
      else
        options[:geometry] = geometry_second
        thumb = Paperclip::Thumbnail.new(file, options, attachment)
        thumb.make
      end
    end
  end

end