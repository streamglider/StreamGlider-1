require 'test_helper'

class FeaturedFeedTest < ActiveSupport::TestCase
  
  test "should create" do
    f = FeaturedFeed.new :logo_file_name => 'test_fn'
    sports = feeds(:cnn)
    assert_difference 'FeaturedFeed.count' do
      sports.featured_feed = f
    end
  end
    
  test "should remove featured feed" do
    cnt = FeaturedFeed.count
    l = featured_feeds(:livematrix)
    f = FeaturedFeed.new :logo_file_name => 'test_fn'
    l.feed.featured_feed = f
    
  end
  
  test "should move up" do
    s = featured_feeds(:sports)
    s.move_up
    
    s = FeaturedFeed.find 2
    assert_equal s.position, 1
    
    lm = FeaturedFeed.find 1
    assert_equal lm.position, 2
  end
  
  test "should move down" do
    s = featured_feeds(:sports)
    s.move_down
    
    s = FeaturedFeed.find 2
    assert_equal s.position, 3
    
    nyt = FeaturedFeed.find 3
    assert_equal nyt.position, 2    
  end
  
end
