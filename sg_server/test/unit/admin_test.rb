require 'test_helper'

class AdminTest < ActiveSupport::TestCase
  test "should create" do
    admin = Admin.new :name => 'test_admin', :password => 'test_pwd', :password_confirmation => 'test_pwd', 
      :email => 'test@somewhere.com'
      
    assert_difference 'Admin.count' do  
      assert admin.save
    end        
  end
  
end
