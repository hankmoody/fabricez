class User < ActiveRecord::Base
  
  # Callbacks
  before_save :attach_default_role
  before_create :set_default_values, :attach_default_collection
  before_destroy :destroy_all_fabrics

  #:confirmable
  devise :database_authenticatable, :registerable, :recoverable, 
         :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :role, :username
  
  validates_presence_of  :email, :username  # password is automatically validated by devise
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
  
  # Scopes and Methods
  def get_for_display_type (display_type = "published")
    # display_type = all : show all designs
    # display_type = published : published = true, processed = true
    # display_type = unprocessed : published = false, processed = false
    # display_type = pending_review : published = false, processed = true;      
    if (display_type == "published")
      fabrics.where(published: true, processed: true)
    elsif (display_type == "unprocessed")
      fabrics.where(published: false, processed: false)
    elsif (display_type == "pending_review")
      fabrics.where(published: false, processed: true)
    else
      # show all
      fabrics.all
    end
  end  
  
  def to_jq_upload
    {
      "limit" => self.role.limit,
      "uploaded_count" => self.fabrics.count
    }
  end  
  
end
