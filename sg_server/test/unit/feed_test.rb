require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  
  test "should create top level" do
    f = Feed.new :title => 'top level feed', :leaf => false
    assert_difference 'Feed.count' do
      assert f.save
    end
  end
  
  test "should create" do
    f = Feed.new :title => 'category feed', :leaf => false
    sports = feeds(:sports)
    assert_difference 'sports.children(true).count' do
      sports.children << f
    end    
  end
  
  test "should create leaf" do
    f = Feed.new :title => 'leaf feed', :leaf => true, :url => 'http://some-rss.url'
    sports = feeds(:sports)
    assert_difference 'sports.children(true).count' do
      sports.children << f
    end      
  end
  
  test "should not create leaf without url or parent" do
    sports = feeds(:sports)
    f = Feed.new :title => 'leaf feed', :leaf => true, :parent => sports
    assert !f.save    
    
    f = Feed.new :title => 'leaf feed', :leaf => true, :url => 'http://some-rss.url'
    assert !f.save  
  end
  
  test "should not create without title" do
    f = Feed.new :leaf => false
    assert !f.save
  end
  
  test "should not create duplicates" do
    sports = feeds(:sports)
    f = Feed.new :title => sports.title, :leaf => false
    assert !f.save
    
    f = Feed.new :title => 'leaf feed', :leaf => true, :url => 'http://some-rss.url'
    sports.children << f
    
    f = Feed.new :title => 'another leaf feed with the same url', :leaf => true, :url => 'http://some-rss.url', :parent => sports
    assert !f.save
  end
  
end
