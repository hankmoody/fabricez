module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      if crop_command
        crop_command + super.join(' ').sub(/ -crop \S+/, '').split(' ')
      else
        super
      end
    end

    def crop_command
      # puts "Debugging::::"
      # puts @attachment.inspect
      # puts @options.inspect
      target = @attachment.instance
      [ "-crop", "#{target.crop_w}x#{target.crop_h}+#{target.crop_x}+#{target.crop_y}" ]
    end
  end
end