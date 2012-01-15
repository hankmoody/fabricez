class User < ActiveRecord::Base
  
  # Callbacks
  before_save :attach_default_role
  before_create :set_default_values
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

  def attach_default_role
    Role.where(category: 'free').first.users.push(self) if role.nil?
  end
  
  def set_default_values
    self.usertype ||= 'consumer'
    self.detail ||= Detail.create
  end
  
  def destroy_all_fabrics
    self.collections.each {|c| c.destroy_all_fabrics }
  end
end
