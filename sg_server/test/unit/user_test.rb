require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "should create" do
    u = User.new :email => "test@nowhere.com", :password => "test pwd"
    
    assert_difference 'User.count' do
      assert u.save
    end    
  end
  
  test "should not create with duplicate email" do
    ian = users(:ian)
    u = User.new :email => ian.email, :password => "test pwd"
    assert !u.save
  end
  
end
