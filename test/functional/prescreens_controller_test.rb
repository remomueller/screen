require 'test_helper'

class PrescreensControllerTest < ActionController::TestCase
  setup do
    @prescreen = prescreens(:one)
    login(users(:admin))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:prescreens)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create prescreen" do
    assert_difference('Prescreen.count') do
      post :create, prescreen: @prescreen.attributes
    end

    assert_redirected_to prescreen_path(assigns(:prescreen))
  end

  test "should show prescreen" do
    get :show, id: @prescreen
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @prescreen
    assert_response :success
  end

  test "should update prescreen" do
    put :update, id: @prescreen, prescreen: @prescreen.attributes
    assert_redirected_to prescreen_path(assigns(:prescreen))
  end

  test "should destroy prescreen" do
    assert_difference('Prescreen.current.count', -1) do
      delete :destroy, id: @prescreen
    end

    assert_redirected_to prescreens_path
  end
end
