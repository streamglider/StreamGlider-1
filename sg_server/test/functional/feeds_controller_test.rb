require 'test_helper'

class FeedsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @feed = feeds(:news)
    request.env["devise.mapping"] = Devise.mappings[:admin]    
    sign_in admins(:joe)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:feeds)
    assert_equal 4, assigns(:feeds).count
  end

  test "should get new for category" do
    get :new, :leaf => false, :parent_id => @feed.id
    assert_response :success
    assert_equal assigns(:feed).parent, @feed
  end
  
  test "should get new for leaf" do
    get :new, :leaf => true, :parent_id => @feed.id
    assert_response :success
    assert_equal assigns(:feed).parent, @feed    
  end
  
  test "should not get new for leaf without parent" do
    get :new, :leaf => true
    assert_redirected_to root_path
  end

  test "should create category" do
    f = Feed.new :title => 'new test category'
    assert_difference('Feed.count') do
      post :create, :feed => f.attributes
    end
  
    assert_redirected_to feeds_path
  end
  
  test "should create feed" do
    f = Feed.new :title => 'new test feed', :parent_id => @feed.id, :url => 'newtestfeed.url', :leaf => true
    assert_difference('Feed.count') do
      post :create, :feed => f.attributes
    end
  
    assert_redirected_to feed_path(assigns(:feed).parent)
  end
  
  test "should show feed" do
    get :show, :id => @feed.to_param
    assert_response :success
    assert !assigns(:contains_leaf_feeds)
  end
  
  test "should get edit" do
    get :edit, :id => @feed.to_param
    assert_response :success
  end
  
  test "should update feed" do
    @feed.title = "new news title"
    put :update, :id => @feed.to_param, :feed => { :title => @feed.title }
    assert_redirected_to feeds_path
    assert_equal Feed.find(@feed.id).title, "new news title"
  end
  
  test "should destroy feed" do
    assert_difference('Feed.count', -1) do
      delete :destroy, :id => @feed.to_param
    end
  
    assert_redirected_to feeds_path
  end
  
  test "should return json index" do
    get :index, :format => :json
    assert_response :success
  end
  
end
