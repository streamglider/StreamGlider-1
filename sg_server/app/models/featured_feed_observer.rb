class FeaturedFeedObserver < ActiveRecord::Observer
    
  def before_destroy(ff)
    # update all featured feeds after this one
    if ff.position < FeaturedFeed.count
      FeaturedFeed.where('position > ?', ff.position).update_all('position = position - 1')      
    end
    true        
  end
          
end