class Fabric < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  has_many :fabric_tags, dependent: :destroy
  has_many :tags, through: :fabric_tags, after_remove: :destroy_empty_tag
  delegate :patterns, :weaves, :others, :best_fors, 
           :seasons, :contents, :materials, to: :tags
  
  has_and_belongs_to_many :collections
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
  Tag.get_default_type_list.each do |type|
    virtual_attr_name = "#{type.underscore}_tag_list"

    define_method virtual_attr_name do
      self.tags.where(type: type).pluck(:name).join(', ')
    end
    
    define_method "#{virtual_attr_name}=" do |names|
      name_list = names.split(',').map { |n| n.strip }
      new_tags = name_list.map {|n| Tag.find_or_create_by!(type: type, name: n) }
      scoped_tags = self.tags.where(type: type)
      self.tags.delete(scoped_tags - new_tags)
      self.tags << new_tags - scoped_tags
    end
  end

  def destroy_empty_tag (tag)
    tag.destroy_me
  end

  def cropping?
    !cropping.nil? && cropping
  end

  def attachment_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
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
       
    def filter (params)
      filter = FabricFilter.new (params)
      filter.build_query
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


private
  

end


class FabricFilter

  def initialize (params)
    @params = ParamsParser.new (params)
  end

  def build_query
    return Fabric.scoped unless @params.found

    initialize_queries
    filter_for_reed_pick
    filter_for_yarn_count
    filter_for_width
    filter_for_tags
    combine_queries
  end

  private

    def initialize_queries
      @or_bucket = Array.new
      @query_bucket = Array.new
      @base_query = Fabric
      use_collection_if_present
    end

    def combine_queries
      if @query_bucket.empty?
        @base_query
      else
        @query_bucket.reduce(:&) # This will run individual SQL query
      end
    end

    def use_collection_if_present
      @base_query = Collection.where(id: @params.collection_id).joins(:fabrics) unless @params.collection_id.nil?
    end

    def filter_for_reed_pick
      p @params.reed_pick
      # @base_query = @base_query
      #                 .joins(:reed_pick)
      #                 .where(reed_picks: @params.reed_pick) unless @params.reed_pick.empty?

      query = @base_query.joins(:reed_pick)
      @params.reed_pick.each { |rp| @query_bucket << query.where(reed_picks: rp).distinct }
    end

    def filter_for_yarn_count
      @base_query = @base_query
                      .joins(:yarn_count)
                      .where(yarn_counts: @params.yarn_count) unless @params.yarn_count.empty?
    end

    def filter_for_width
      @base_query = @base_query.where(width: @params.width) unless @params.width.nil?
    end

    def filter_for_tags
      query = @base_query.joins(:tags) unless @params.tags.empty?
      @params.tags.each { |type, names| @query_bucket << query.where(tags: {type: type, name: names}).distinct }
    end

end


class ParamsParser
  attr_reader :tags, :found, :collection_id, :reed_pick, :yarn_count, :width

  def initialize (params)
    @params = params
    @found = false
    parse_params
  end

  private

    def parse_params
      parse_collection
      parse_reed_pick
      parse_yarn_count
      parse_width
      parse_tags
    end

    def parse_collection
      @collection_id = @params['collection']
      @found |= ! @collection_id.nil?
    end

    def parse_reed_pick
      list = list_from_comma_delimited(@params['reed_pick'])
      @reed_pick = list.map { |rp| ReedPick.parse_string(rp) }
      @found |= ! @reed_pick.empty?
    end

    def parse_yarn_count
      @yarn_count = YarnCount.parse(@params['yarn_count'])
      @found |= ! @yarn_count.empty?
    end

    def parse_width
      @width = @params['width']
      if ! @width.nil?
        @width = @width.split(',').map {|s| s.strip.to_i }
        @found = true
      end
    end

    def parse_tags
      @tags = {}
      types = Tag.get_type_list
      @params.each { |key, value| @tags = @tags.merge(key => value) if types.include?(key) }
      @found |= ! @tags.empty?
    end

    def list_from_comma_delimited (str)
      str.nil? ? [] : str.split(',').map { |s| s.strip }
    end

end