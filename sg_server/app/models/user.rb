class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :newsletter
  
  validates_presence_of :email
  validates_uniqueness_of :email
  
  before_save :ensure_authentication_token  
  has_many :streams, :order => 'position'
  
  has_many :incoming_streams, :class_name => 'ShareTo'
    
end
