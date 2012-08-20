class User < ActiveRecord::Base
  
  # Callbacks
  before_save :attach_default_role
  before_create :set_default_values, :attach_default_collection
  before_destroy :destroy_all_fabrics

  #:confirmable
  devise :database_authenticatable, :registerable, :recoverable, 
         :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :role, :username,
                  :detail_attributes
  
  validates_presence_of  :email  # password is automatically validated by devise
  validates_uniqueness_of :username, :email, :case_sensitive => false

  has_many :collections, dependent: :destroy
  has_many :fabrics, :through => :collections, dependent: :destroy
  has_one :detail, dependent: :destroy
  belongs_to :role

  accepts_nested_attributes_for :detail

  def attach_default_role
    Role.where(category: 'free').first.users.push(self) if role.nil?
  end
  
  def attach_default_collection
    self.collections << Collection.create(name:"default") unless self.collections.where(name:"default").exists?
  end
  
  def set_default_values
    self.usertype ||= 'consumer'
    self.detail ||= Detail.create
  end
  
  def destroy_all_fabrics
    self.collections.each {|c| c.destroy_all_fabrics }
  end
  
  def add_fabric_to_collection (f, cname)
    self.collections.where(name: cname).first.fabrics.push(f)
  end

  def add_fabrics_to_collection (fabrics, cid)
    fabrics.each do |f|
      self.collections.where(id: cid).first.fabrics.push(f)
    end
  end

  def remove_fabric (fid)
    Fabric.destroy(fid)
    # self.collections.each { |c| c.fabrics.where(id: fid).destroy }
  end
  
  def remove_fabric_from_collection(fid, cname)
    self.collections.where(name: cname).first.fabrics.where(id: fid).destroy
  end
  
  def owns_fabric? (f)
    fabrics.include?(f)
  end
    
  def get_next_unproc
    # Return next unprocessed fabric in the list
    get_for_display_type("unprocessed").first
  end
  
  def add_collection_name (c_name)
    bAlreadyExists = self.collections.where("name ILIKE ?", c_name).exists?
    self.collections << Collection.create(name:c_name) unless bAlreadyExists
    return !bAlreadyExists
  end
  
  def remove_collection_name (c_name)
    self.collections.where("name ILIKE ?", c_name).first.delete
  end
  
  def get_collection_names (no_default)
    # Return all collection names except 'default'
    get_collections(no_default).collect{ |c| c.name }
    # self.collections.collect{|c| c.name unless c.name.eql?('default')}.compact
  end
  
  def get_collections (no_default)
      return self.collections unless no_default
      self.collections.collect{|c| c unless c.name.eql?('default')}.compact
  end
  
  # Scopes and Methods
  def get_for_display_type (display_type = "published", collection_name = 'default')
    # display_type = all : show all designs
    # display_type = published : published = true, processed = true
    # display_type = unprocessed : published = false, processed = false
    # display_type = pending_review : published = false, processed = true;      
    
    coll = collections.where(name: collection_name).first
    
    if (display_type == "published")
      coll.fabrics.where(published: true, processed: true)
    elsif (display_type == "unprocessed")
      coll.fabrics.where(published: false, processed: false)
    elsif (display_type == "pending_review")
      coll.fabrics.where(published: false, processed: true)
    else
      # show all
      coll.fabrics.all
    end
  end  
  
  def to_jq_upload
    {
      "limit" => self.role.limit,
      "uploaded_count" => self.fabrics.count
    }
  end  
  
end
