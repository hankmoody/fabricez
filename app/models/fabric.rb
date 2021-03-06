class Fabric < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  has_and_belongs_to_many :collections
  has_and_belongs_to_many :tags
  has_one :reed_pick, dependent: :destroy
  has_one :yarn_count, dependent: :destroy
  has_many :colors, dependent: :destroy
  
  accepts_nested_attributes_for :yarn_count, :reed_pick, :colors, :allow_destroy => true
  
  attr_accessor :cropping
  
  # Paperclip attachment
  has_attached_file :attachment,
    :storage => :s3,
    :styles => {
      :original => {:geometry => '850x500>', 
                    :format => 'JPG'},
      :big => {:geometry => '600x400#', 
               :format => 'JPG', 
               :processors => [:cropper] },
      :thumb => {:geometry => '200x200>',
                 :format => 'JPG', 
                 :processors => [:cropper, :thumbnail]}
    },
    :url => "/images/:attachment/:id/:style/:basename.:extension",
    :path => "/images/:attachment/:id/:style/:basename.:extension",
    :bucket => Fabricez::Application.config.s3_attachment_bucket,
    :s3_host_alias => Fabricez::Application.config.s3_host_alias,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :convert_options => {:original => "-quality 80 -strip",
                         :big => "-quality 80 -strip",
                         :thumb => "-quality 90 -strip" }
  
  after_save :check_for_processed

  validates_presence_of :code
  validates_format_of :quantity, :with => /\A\d*\.?\d*\z/, :allow_blank => true
  validates_format_of :width, :with => /\A\d*\z/, :allow_blank => true
  validates_format_of :price, :with => /\A\d*\.?\d*\z/, :allow_blank => true
  
  # Virtual Attributes
  ['pattern', 'other', 'contents', 'best_for', 'weave', 'season'].each do |name|
    virt_attr_name = "#{name}_tag_list"
    #attr_accessible virt_attr_name.to_sym

    define_method virt_attr_name do
      tag_list(name)
    end
    
    define_method "#{virt_attr_name}=" do |tags_param|
      set_tag_list(tags_param, name)
    end
  end
  
  def cropping?
    !cropping.nil? && cropping
  end

  def attachment_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end
  
  def remove_tag(r_tag)
    r_tag.destroy if r_tag.tagtype == "other" || r_tag.tagtype == "contents"
    tags.delete(r_tag)
  end


  def set_tag_list (tags_param, tag_type)
    
    if tags_param.empty?
      removal_array = []  # Use this array to collects tags before deletion. DO NOT DELETE SINGLE ITEM IN A LOOP!
      self.tags.each do |t|
        removal_array << t if t.tagtype == tag_type
      end
      removal_array.each { |r| remove_tag r }              
    end
    
    tag_array = []
    tag_array = tags_param.split(",").collect{ |t| t.strip }.delete_if{ |t| t.blank? } if !tags_param.empty?
    if (!tag_array.empty?)
      tag_obj_array = Array.new
      tag_array.each do |tag|
        tag = tag.split('-').map{|t| t.titleize}.join('-')
        #  ****  NOTE **** LIKE will have to changed to ILIKE for Postgres 
        if Tag.where("name LIKE ?", tag).exists?
          tag_obj_array << Tag.where("name LIKE ?", tag).first
        else
          tag_obj_array << Tag.create(name: tag, tagtype: tag_type)
        end
      end
      
      removal_array = []
      self.tags.each do |tag|
        if tag.tagtype == tag_type
          removal_array << tag if !tag_obj_array.include?(tag)
          # remove_tag tag if !tag_obj_array.include?(tag)
        end  
      end
      removal_array.each { |r| remove_tag r } 
      
      tag_obj_array.each do |n_tag|
        self.tags << n_tag unless self.tags.include?(n_tag)
      end
    end
    puts "DEBUG: Pattern Tag List is #{self.pattern_tag_list}" if tag_type == "pattern"
  end
  
  def tag_list (tag_type=nil)
    tag_array = self.tag_names(tag_type)
    tag_array.join(", ") unless tag_array.empty?
  end
  
  def tag_names (tag_type=nil)
    if tag_type.nil?
      tags.collect{ |t| t.name }.flatten.compact
    else
      tags.collect{ |t| t.name if t.tagtype == tag_type }.flatten.compact
    end
  end
  
  def to_jq_upload
    {
      "name" => attachment_file_name,
      "size" => attachment_file_size,
      "url" => attachment.url(:original),
      "thumbnail_url" => attachment.url(:thumb),
      "delete_url" => fabric_path(:id => id),
      "delete_type" => "DELETE"
    }
  end
  
  def check_for_processed
    if !self.processed
      if !self.code.nil? && self.code != "Unprocessed"
        self.processed = true
        self.save
      end
    end
  end  
  
  def extract_color_info
    selected_colors = Color.extract_color_information(attachment)
    
    puts "Total number of colors found: #{selected_colors.count}\n"
    selected_colors.each do |color|
      self.colors << Color.create(red: color[:red], 
                                  green: color[:green],
                                  blue: color[:blue],
                                  coverage: color[:coverage])
    end    
  end
  
  def update_tags(tag_params)
    tag_params.each do |t_params|
      n_tags = t_params[:list].split(",").collect{ |t| t.strip }.delete_if{ |t| t.blank? }
      e_tags = tag_names(t_params[:tag_type])
      e_tags = ((t_params[:action] == 'remove') ? e_tags - n_tags : e_tags + n_tags).uniq
      puts t_params.inspect
      puts e_tags.inspect
      set_tag_list(e_tags.join(", "), t_params[:tag_type])
    end
    save!
  end
  
  class << self
    
    def filter_fabrics(params, fab_array = nil)
      
      # Return all fabrics if none of the filters have been selected
      filter_key_list = tag_key_list = Tag.get_tagtype_list
      filter_key_list += [ 'width', 'yarn_count', 'color']
      filters_found = false
      tags_found = false
      
      @fab_q = nil
      coll_id = (params.keys.include?('collection')) ? params['collection'] : nil
      if coll_id
        Collection.find(coll_id).fabrics
      else
        @fab_q = (fab_array) ? fab_array : Fabric.all
      end
      
      # puts "DEBUG"
      # puts filter_key_list.inspect
      # puts params.inspect
      
      params.each_pair do |key, value|
        tags_found = true if tag_key_list.include?(key)
        filters_found = true if filter_key_list.include?(key)
      end
      return @fab_q unless filters_found
      
      puts "DEBUG filters found!"
      
      filtered_fabrics = @fab_q
      if params.keys.include?('color')
        filtered_fabrics &= Color.filter(params[:color], params[:tolerance].to_f).each.collect {|c| c.fabric}
      end
      
      if tags_found
        filtered_fabrics &= filter_by_tags(params)
      end
      
      return filtered_fabrics
      
    end
    
    def filter_by_tags(params)
      # Tag search
      #  - By default all tags from same type will be OR'd
      #  - By default all tags from different type will be AND'ed
      
      result = [];
      count = 0;
      tag_type_list = Tag.get_tagtype_list
      params.each_pair do |key, value|
        if tag_type_list.include?(key)
          if count == 0
            # @fab_q = Collection.find(params['collection']).fabrics
            result = @fab_q.joins(:tags).where('tags.name' => value)
          else
            result = result & @fab_q.joins(:tags).where('tags.name' => value)
          end
          count+=1
        end
      end
      result
    end
    
    def get_for_display_type (display_type = "published")
      # display_type = published : published = true, processed = true
      # display_type = unprocessed : published = false, processed = false
      # display_type = pending_review : published = false, processed = true;      
      if (display_type == "published")
        Fabric.where(published: true, processed: true)
      elsif (display_type == "unprocessed")
        Fabric.where(published: false, processed: false)
      elsif (display_type == "pending_review")
        Fabric.where(published: false, processed: true)
      else
        # show published
        Fabric.where(published: true, processed: true)
      end
    end    
    
    def get_distinct_width
      Fabric.select("distinct width").map{ |f| f.width  }.compact
    end
    
    def get_distinct_yarncount
      YarnCount.all.map { |y| y.full_count }.uniq.compact
    end
    
    def get_distinct_reedpick
      ReedPick.all.map { |r| r.full_reed_pick }.uniq.compact
    end
    
  end  
  
end
