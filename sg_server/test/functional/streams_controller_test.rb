require 'test_helper'

class StreamsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  
  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]    
    sign_in users(:ian)
    @stream = streams(:first)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:streams)
  end

  test "should create stream" do
    assert_difference('Stream.count') do
      post :create, :stream => @stream.attributes
    end

    assert_response :success
  end

  test "should show stream" do
    get :show, :id => @stream.to_param
    assert_response :success
  end

  test "should update stream" do
    put :update, :id => @stream.to_param, :stream => @stream.attributes
    assert_response :success
  end

  test "should destroy stream" do
    assert_difference('Stream.count', -1) do
      delete :destroy, :id => @stream.to_param
    end

    assert_response :success
  end
end
