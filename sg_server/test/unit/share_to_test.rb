require 'test_helper'

class ShareToTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "should create" do
    st = ShareTo.new :user => users(:ian), :stream => streams(:first)
    assert_difference 'ShareTo.count' do
      st.save
    end
    
  end
  
end
