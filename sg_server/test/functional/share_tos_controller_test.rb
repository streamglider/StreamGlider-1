require 'test_helper'

class ShareTosControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]    
    sign_in users(:ian)
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:share_tos)
  end

  test "should destroy share_to" do
    assert_difference('ShareTo.count', -1) do
      delete :destroy, :id => share_tos(:from_ian).to_param
    end
    
    assert_response :success
  end
end
