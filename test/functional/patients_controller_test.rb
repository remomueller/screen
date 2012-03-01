require 'test_helper'

class PatientsControllerTest < ActionController::TestCase
  setup do
    @patient = patients(:one)
    login(users(:admin))
  end

  test "should get inline update" do
    post :inline_update, id: @patient, item: 'city', update_value: 'Boston', format: 'js'

    assert_not_nil assigns(:patient)
    assert_equal 'Boston', assigns(:patient).city
    assert_template 'inline_update'
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:patients)
  end

  test "should get index with js" do
    get :index, format: 'js', mrn: '0'
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:patients)
    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create patient" do
    assert_difference('Patient.count') do
      post :create, patient: { mrn: '0123456789', first_name: 'FirstName', last_name: 'LastName', address1: 'Address 1', city: 'City', state: 'State', zip: 'zip', phone_home: '1112223333' }
    end

    assert_redirected_to patient_path(assigns(:patient))
  end

  test "should not create patient with blank MRN" do
    assert_difference('Patient.count', 0) do
      post :create, patient: { mrn: '', first_name: 'FirstName', last_name: 'LastName', address1: 'Address 1', city: 'City', state: 'State', zip: 'zip', phone_home: '1112223333' }
    end

    assert_not_nil assigns(:patient)
    assert assigns(:patient).errors.size > 0
    assert_equal ["can't be blank"], assigns(:patient).errors[:mrn]
    assert_template 'new'
  end

  test "should show patient" do
    get :show, id: @patient
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @patient
    assert_response :success
  end

  test "should update patient" do
    put :update, id: @patient, patient: { first_name: 'FirstNameUpdate' }
    assert_redirected_to patient_path(assigns(:patient))
  end

  test "should not update patient with blank MRN" do
    put :update, id: @patient, patient: { first_name: 'FirstNameUpdate', mrn: '' }
    assert_not_nil assigns(:patient)
    assert assigns(:patient).errors.size > 0
    assert_equal ["can't be blank"], assigns(:patient).errors[:mrn]
    assert_template 'edit'
  end

  test "should destroy patient" do
    assert_difference('Patient.current.count', -1) do
      delete :destroy, id: @patient
    end

    assert_redirected_to patients_path
  end
end
