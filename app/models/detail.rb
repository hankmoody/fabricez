class Detail < ActiveRecord::Base
  
  belongs_to :user
  
  # Paperclip attachment
  has_attached_file :logo,
      :storage => :s3,
      :styles => {
        :original => {:geometry => '200x200>'},
      },
      :url => "/images/logo/:id/:style/:basename.:extension",
      :path => "/images/logo/:id/:style/:basename.:extension",
      :bucket => Fabricez::Application.config.s3_attachment_bucket,
      :s3_host_alias => Fabricez::Application.config.s3_host_alias,
      :s3_credentials => "#{Rails.root}/config/s3.yml",
      :convert_options => {:original => "-quality 80 -strip" }
  

end
