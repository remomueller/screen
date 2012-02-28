require 'test_helper'

class CallsControllerTest < ActionController::TestCase
  setup do
    @call = calls(:one)
    login(users(:admin))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:calls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create call" do
    assert_difference('Call.count') do
      post :create, call: { patient_id: @call.patient_id }, call_date: "02/28/2012", call_time: "5:45pm"
    end

    assert_redirected_to call_path(assigns(:call))
  end

  test "should show call" do
    get :show, id: @call
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @call
    assert_response :success
  end

  test "should update call" do
    put :update, id: @call, call: { patient_id: @call.patient_id }, call_date: "02/28/2012", call_time: "5:50pm"
    assert_redirected_to call_path(assigns(:call))
  end

  test "should destroy call" do
    assert_difference('Call.current.count', -1) do
      delete :destroy, id: @call
    end

    assert_redirected_to calls_path
  end
end
