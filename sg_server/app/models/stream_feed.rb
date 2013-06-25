class StreamFeed < ActiveRecord::Base  
  
  belongs_to :stream
  
  acts_as_list :scope => :stream
  
  validates :stream, :title, :feed_type, :url, :presence => true
  
  def as_json(options)
    { :title => self.title, :url => self.url, :feed_type => self.feed_type, :position => self.position, :id => self.id }
  end  
  
end
