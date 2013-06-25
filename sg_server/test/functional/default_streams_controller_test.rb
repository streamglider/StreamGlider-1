require 'test_helper'

class DefaultStreamsControllerTest < ActionController::TestCase
  setup do
    @default_stream = default_streams(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:default_streams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create default_stream" do
    assert_difference('DefaultStream.count') do
      post :create, :default_stream => @default_stream.attributes
    end

    assert_redirected_to default_stream_path(assigns(:default_stream))
  end

  test "should show default_stream" do
    get :show, :id => @default_stream.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @default_stream.to_param
    assert_response :success
  end

  test "should update default_stream" do
    put :update, :id => @default_stream.to_param, :default_stream => @default_stream.attributes
    assert_redirected_to default_stream_path(assigns(:default_stream))
  end

  test "should destroy default_stream" do
    assert_difference('DefaultStream.count', -1) do
      delete :destroy, :id => @default_stream.to_param
    end

    assert_redirected_to default_streams_path
  end
end
