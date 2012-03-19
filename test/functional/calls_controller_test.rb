require 'test_helper'

class CallsControllerTest < ActionController::TestCase
  setup do
    @call = calls(:one)
    login(users(:screener))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:calls)
  end

  test "should get index with js" do
    get :index, format: 'js', mrn: '0'
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:calls)
    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new, patient_id: patients(:one)
    assert_response :success
  end

  test "should create call" do
    assert_difference('Call.count') do
      post :create, call: { patient_id: @call.patient_id, call_type: choices(:call_type), direction: 'incoming' }, call_date: "02/28/2012", call_time: "5:45pm"
    end

    assert_not_nil assigns(:call)
    assert_equal users(:screener), assigns(:call).user
    assert_redirected_to patient_path(assigns(:call).patient)
  end

  test "should not create call with blank call date" do
    assert_difference('Call.count', 0) do
      post :create, call: { patient_id: @call.patient_id }, call_date: '', call_time: "5:45pm"
    end

    assert_not_nil assigns(:call)
    assert assigns(:call).errors.size > 0
    assert_equal ["can't be blank"], assigns(:call).errors[:call_time]
    assert_template 'new'
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
    put :update, id: @call, call: { patient_id: @call.patient_id, call_type: choices(:call_type), direction: 'incoming' }, call_date: "02/28/2012", call_time: "5:50pm"
    assert_redirected_to call_path(assigns(:call))
  end

  test "should not update call for patient without subject code as subject handler" do
    login(users(:subject_handler))
    put :update, id: calls(:without_subject_code), call: { patient_id: calls(:without_subject_code).patient_id, call_type: choices(:call_type), direction: 'incoming' }, call_date: "02/28/2012", call_time: "5:50pm"
    assert_redirected_to root_path
  end

  test "should not update call with blank call date" do
    put :update, id: @call, call: { patient_id: @call.patient_id, call_type: choices(:call_type), direction: 'incoming' }, call_date: "", call_time: "5:50pm"
    assert_not_nil assigns(:call)
    assert assigns(:call).errors.size > 0
    assert_equal ["can't be blank"], assigns(:call).errors[:call_time]
    assert_template 'edit'
  end

  test "should destroy call" do
    assert_difference('Call.current.count', -1) do
      delete :destroy, id: @call
    end

    assert_redirected_to calls_path
  end

  test "should not destroy call for patient without subject code as subject handler" do
    login(users(:subject_handler))
    assert_difference('Call.current.count', 0) do
      delete :destroy, id: calls(:without_subject_code)
    end

    assert_redirected_to root_path
  end
end
