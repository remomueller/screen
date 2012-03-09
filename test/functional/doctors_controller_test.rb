require 'test_helper'

class DoctorsControllerTest < ActionController::TestCase
  setup do
    @doctor = doctors(:one)
    login(users(:screener))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:doctors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create doctor" do
    assert_difference('Doctor.count') do
      post :create, doctor: { name: 'DoctorThree' }
    end

    assert_not_nil assigns(:doctor)
    assert_equal users(:screener), assigns(:doctor).user
    assert_redirected_to doctor_path(assigns(:doctor))
  end

  test "should not create doctor with blank name" do
    assert_difference('Doctor.count', 0) do
      post :create, doctor: { name: '' }
    end

    assert_not_nil assigns(:doctor)
    assert assigns(:doctor).errors.size > 0
    assert_equal ["can't be blank"], assigns(:doctor).errors[:name]
    assert_template 'new'
  end

  test "should show doctor" do
    get :show, id: @doctor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @doctor
    assert_response :success
  end

  test "should update doctor" do
    put :update, id: @doctor, doctor: { name: 'DoctorOneUpdate' }
    assert_redirected_to doctor_path(assigns(:doctor))
  end

  test "should update and whitelist doctor" do
    put :update, id: @doctor, doctor: { status: 'whitelist' }, from: 'prescreens'
    assert_not_nil assigns(:doctor)
    assert 'whitelist', assigns(:doctor).status
    assert_redirected_to prescreens_path
  end

  test "should update and blacklist doctor" do
    put :update, id: @doctor, doctor: { status: 'blacklist' }, from: 'prescreens'
    assert_not_nil assigns(:doctor)
    assert 'blacklist', assigns(:doctor).status
    assert_redirected_to prescreens_path
  end

  test "should not update doctor with blank name" do
    put :update, id: @doctor, doctor: { name: '' }
    assert_not_nil assigns(:doctor)
    assert assigns(:doctor).errors.size > 0
    assert_equal ["can't be blank"], assigns(:doctor).errors[:name]
    assert_template 'edit'
  end

  test "should destroy doctor" do
    assert_difference('Doctor.current.count', -1) do
      delete :destroy, id: @doctor
    end

    assert_redirected_to doctors_path
  end
end
