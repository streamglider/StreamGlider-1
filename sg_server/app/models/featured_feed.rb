# this model represents a featured feed, displayed on "Featured" page in edit mode
class FeaturedFeed < ActiveRecord::Base  
  
  belongs_to :feed
  
  has_attached_file :logo
  
  validates_presence_of :feed
  validates_attachment_presence :logo 
  
  default_scope order('position ASC')
  
  def logo_url
    logo.url
  end
  
  def as_json(options)
    super(:only => [:id], :include => { :feed => { :only => [:title, :url, :feed_type] } }, :methods => [:logo_url])   
  end
  
  def move_to_position(new_position)
    return if self.position == new_position
    
    if (self.position > new_position)
      # update all featured feeds after new index up to old index
      FeaturedFeed.where('position >= ? AND position < ?', new_position, self.position).update_all('position = position + 1')
      self.position = new_position
      self.save!
    else
      # update all featured feeds after old index up to new index
      FeaturedFeed.where('position > ? AND position <= ?', self.position, new_position).update_all('position = position - 1')
      self.position = new_position
      self.save!      
    end
  end
  
  def move_to_top
    move_to_position(1)
  end
  
  def move_to_bottom
    move_to_position(FeaturedFeed.count)    
  end
  
  def move_up
    if self.position > 1
      move_to_position(self.position - 1)
    end
  end
  
  def move_down
    if self.position < FeaturedFeed.count
      move_to_position(self.position + 1)
    end
  end
    
end
