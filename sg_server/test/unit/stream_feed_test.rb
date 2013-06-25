require 'test_helper'

class StreamFeedTest < ActiveSupport::TestCase
  
  test "should create" do
    s = StreamFeed.new :title => "test feed", :url => "test url", :feed_type => "YouTube", :position => 2
    assert_difference 'StreamFeed.count' do
      streams(:first).stream_feeds << s
    end
  end
  
end
