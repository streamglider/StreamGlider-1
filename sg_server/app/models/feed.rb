# This model represents a node in the feed sources hierarchy.
# it supports both FeedSource and FeedSourceCategory from StreamGlider client.
# "leaf" property allows to distinguish between FeedSource and FeedSourceCategory, e.g. if leaf == 1 then 
# we have a FeedSource and vice versa
class Feed < ActiveRecord::Base  
  # child nodes, can be empty
  has_many :children, :class_name => "Feed", :dependent => :destroy, :foreign_key => 'parent_id'
  
  # parent node, can be empty
  belongs_to :parent, :class_name => "Feed"
  
  # featured feed, optional
  has_one :featured_feed, :dependent => :destroy
  
  has_attached_file :image  
  
  validates :title, :feed_type, :presence => true
  
  validates_presence_of :parent_id, :if => :leaf
  validates_presence_of :url, :if => :leaf
  
  validates_uniqueness_of :url, :scope => :parent_id, :if => :leaf
  validates_uniqueness_of :title, :scope => :parent_id, :unless => :leaf
  
  def as_json(options)
    # allows 2 levels of children in feeds hierarchy
    if leaf
      { :title => self.title, :url => self.url, :feed_type => self.feed_type }
    else
      ch_arr = self.children.order('position ASC').map {|child| child.as_json(options)}      
      { :title => self.title, :image_url => self.image.url, :children => ch_arr }
    end
  end
  
  def self.feed_types
    [["RSS", "RSS"], ["Twitter", "Twitter"], ["YouTube", "YouTube"], ["Facebook", "Facebook"], ["Flickr", "Flickr"]]
  end
  
  def move_to_position(new_position)
    return if self.position == new_position
    
    if (self.position > new_position)
      if self.parent
        # update all featured feeds after new index up to old index
        self.parent.children.where('position >= ? AND position < ?', new_position, self.position).update_all('position = position + 1')
      else
        Feed.where('parent_id IS NULL AND (position >= ? AND position < ?)', new_position, self.position).update_all('position = position + 1')
      end
      self.position = new_position
      self.save!
    else
      # update all featured feeds after old index up to new index
      if self.parent
        self.parent.children.where('position > ? AND position <= ?', self.position, new_position).update_all('position = position - 1')
      else
        Feed.where('parent_id IS NULL AND (position > ? AND position <= ?)', self.position, new_position).update_all('position = position - 1')
      end  
      self.position = new_position
      self.save!      
    end
  end
  
  def move_to_top
    move_to_position(1)
  end
  
  def move_to_bottom
    cnt = self.parent ? self.parent.children.count : Feed.where(:parent_id => nil).count
    move_to_position(cnt)    
  end
  
  def move_up
    if self.position > 1
      move_to_position(self.position - 1)
    end
  end
  
  def move_down
    cnt = self.parent ? self.parent.children.count : Feed.where(:parent_id => nil).count
    if self.position < cnt
      move_to_position(self.position + 1)
    end
  end
    
end
