class FeedObserver < ActiveRecord::Observer
    
  def before_destroy(feed)
    # update all featured feeds after this one
    cnt = feed.parent ? feed.parent.children.count : Feed.where(:parent_id => nil).count
    if feed.position < cnt
      if feed.parent
        feed.parent.children.where('position > ?', feed.position).update_all('position = position - 1')      
      else
        Feed.where('position > ? AND parent_id IS NULL', feed.position).update_all('position = position - 1')      
      end
    end
    true        
  end
          
end