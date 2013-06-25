require 'test_helper'

class FeaturedFeedsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    request.env["devise.mapping"] = Devise.mappings[:admin]    
    sign_in admins(:joe)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:featured_feeds)
  end
  
  test "should get new" do
    get :new, :feed_id => feeds(:sports)
    assert_response :success
  end
  
  test "should not get new w/o feed_id" do    
    get :new
    assert_redirected_to root_path
  end
  
  test "should not create featured feed w/o logo" do
    f = FeaturedFeed.new :feed => feeds(:sports)
    post :create, :featured_feed => f.attributes
  
    assert_response :success
  end
  
  
  test "should show featured feed" do
    get :show, :id => featured_feeds(:livematrix)
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => featured_feeds(:livematrix)
    assert_response :success
  end
  
  
  test "should not update featured feed w/o logo" do
    f = featured_feeds(:livematrix)
    put :update, :id => f.to_param, :featured_feed => f.attributes
    assert_response :success
  end
  
  test "should destroy featured_feed" do
    assert_difference('FeaturedFeed.count', -1) do
      delete :destroy, :id => featured_feeds(:livematrix)
    end
  
    assert_redirected_to featured_feeds_path
  end
  
  test "should return json index" do
    get :index, :format => :json
    assert_response :success
  end
  
end
