require 'test_helper'

class StreamFeedsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]    
    sign_in users(:ian)
    @stream_feed = stream_feeds(:nyt)
  end

  test "should create stream feed" do
    assert_difference('StreamFeed.count') do
      post :create, :stream_feed => @stream_feed.attributes, :stream_id => streams(:first).id
    end

    assert_response :success
  end

  test "should show stream feed" do
    get :show, :id => @stream_feed.to_param
    assert_response :success
  end

  test "should update stream feed" do
    put :update, :id => @stream_feed.to_param, :stream => @stream_feed.attributes
    assert_response :success
  end

  test "should destroy stream feed" do
    assert_difference('StreamFeed.count', -1) do
      delete :destroy, :id => @stream_feed.to_param
    end

    assert_response :success
  end
end
