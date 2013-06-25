class Stream < ActiveRecord::Base
  belongs_to :user  
  acts_as_list :scope => :user  
  
  validates :title, :presence => true
  
  validate :validate_user
  
  has_many :stream_feeds, :dependent => :destroy, :order => 'position'
  
  def as_json(options)
    feeds = self.stream_feeds.map {|child| child.as_json(options)}
    { :title => self.title, :position => self.position, :id => self.id, :stream_feeds => feeds}
  end
  
  def validate_user
    if (self.user_id != -1 && !self.user)
      errors.add :base, "User can't be blank"
    end  
  end
  
end
