class UserObserver < ActiveRecord::Observer
  
  def before_destroy(user)
    # remove all share_tos and connected streams
    shares = user.incoming_streams
    shares.each do |share_to|
      # remove stream
      share_to.stream.destroy
    end
    
    user.incoming_streams.destroy_all    
  end
  
end