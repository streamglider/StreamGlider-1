require 'test_helper'

class StreamTest < ActiveSupport::TestCase
  
  test "should create" do
    s = Stream.new :title => "test title", :position => 2
    assert_difference 'Stream.count' do
      users(:ian).streams << s
    end
  end
  
end
