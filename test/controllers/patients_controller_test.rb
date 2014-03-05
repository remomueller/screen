require 'test_helper'

class PatientsControllerTest < ActionController::TestCase
  setup do
    @patient = patients(:one)
    login(users(:screener))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:patients)
  end

  test "should get autocomplete" do
    get :index, autocomplete: 'true', term: '', format: 'js'
    assert_not_nil assigns(:patients)
  end

  test "should get index with js" do
    get :index, format: 'js', mrn: '0'
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:patients)
    assert_template 'index'
    assert_response :success
  end

  test "should get index with js for multiple subject codes" do
    get :index, format: 'js', mrn: ' S1234, S5678 '
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:patients)
    assert_equal ['S1234', 'S5678'], assigns(:patients).pluck(:subject_code)
    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create patient with mrn" do
    assert_difference('Patient.count') do
      post :create, patient: { mrn: '23456789', first_name: 'FirstName', last_name: 'LastName', address1: 'Address 1', city: 'City', state: 'State', zip: 'zip', phone_home: '1112223333' }
    end

    assert_not_nil assigns(:patient)
    assert_equal users(:screener), assigns(:patient).user
    assert_redirected_to patient_path(assigns(:patient))
  end

  test "should create patient with subject code" do
    assert_difference('Patient.count') do
      post :create, patient: { subject_code: '0123456789', first_name: 'FirstName', last_name: 'LastName', address1: 'Address 1', city: 'City', state: 'State', zip: 'zip', phone_home: '1112223333' }
    end

    assert_not_nil assigns(:patient)
    assert_equal users(:screener), assigns(:patient).user
    assert_redirected_to patient_path(assigns(:patient))
  end

  test "should not create patient with blank MRN and blank subject code" do
    assert_difference('Patient.count', 0) do
      post :create, patient: { mrn: '', subject_code: '', first_name: 'FirstName', last_name: 'LastName', address1: 'Address 1', city: 'City', state: 'State', zip: 'zip', phone_home: '1112223333' }
    end

    assert_not_nil assigns(:patient)
    assert assigns(:patient).errors.size > 0
    assert assigns(:patient).errors[:mrn].include?("can't be blank")
    assert_equal ["can't be blank"], assigns(:patient).errors[:subject_code]
    assert_template 'new'
  end

  test "should show patient" do
    get :show, id: @patient
    assert_response :success
  end

  test "should show patient with eleven digit phone" do
    get :show, id: patients(:two)
    assert_response :success
  end

  test "should not show patient without subject code to subject handler" do
    login(users(:subject_handler))
    get :show, id: patients(:without_subject_code)
    assert_redirected_to root_path
  end

  test "should show patient with subject code to subject handler" do
    login(users(:subject_handler))
    get :show, id: patients(:with_subject_code)
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @patient
    assert_response :success
  end

  test "should not edit patient without subject code to subject handler" do
    login(users(:subject_handler))
    get :edit, id: patients(:without_subject_code)
    assert_redirected_to root_path
  end

  test "should edit patient with subject code to subject handler" do
    login(users(:subject_handler))
    get :edit, id: patients(:with_subject_code)
    assert_response :success
  end

  test "should update patient" do
    put :update, id: @patient, patient: { first_name: 'FirstNameUpdate' }
    assert_redirected_to patient_path(assigns(:patient))
  end

  test "should not update patient without subject code to subject handler" do
    login(users(:subject_handler))
    put :update, id: patients(:without_subject_code), patient: { first_name: 'FirstNameUpdate' }
    assert_redirected_to root_path
  end

  test "should update patient with subject code to subject handler" do
    login(users(:subject_handler))
    put :update, id: patients(:with_subject_code), patient: { first_name: 'FirstNameUpdate' }
    assert_redirected_to patient_path(assigns(:patient))
  end

  test "should update patient with MRN and blank subject code" do
    put :update, id: @patient, patient: { first_name: 'FirstNameUpdate', mrn: '00newmrn', subject_code: '' }
    assert_redirected_to patient_path(assigns(:patient))
  end

  test "should update patient with subject code and blank MRN" do
    put :update, id: @patient, patient: { first_name: 'FirstNameUpdate', mrn: '', subject_code: 'newsubjectcode' }
    assert_redirected_to patient_path(assigns(:patient))
  end

  test "should not update patient with blank MRN and blank subject code" do
    put :update, id: @patient, patient: { first_name: 'FirstNameUpdate', mrn: '', subject_code: '' }
    assert_not_nil assigns(:patient)
    assert assigns(:patient).errors.size > 0
    assert assigns(:patient).errors[:mrn].include?("can't be blank")
    assert_equal ["can't be blank"], assigns(:patient).errors[:subject_code]
    assert_template 'edit'
  end

  test "should destroy patient" do
    assert_difference('Patient.current.count', -1) do
      delete :destroy, id: @patient
    end

    assert_redirected_to patients_path
  end

  test "should not destroy patient without subject code to subject handler" do
    login(users(:subject_handler))
    assert_difference('Patient.current.count', 0) do
      delete :destroy, id: patients(:without_subject_code)
    end

    assert_redirected_to root_path
  end

  test "should destroy patient with subject code to subject handler" do
    login(users(:subject_handler))
    assert_difference('Patient.current.count', -1) do
      delete :destroy, id: patients(:with_subject_code)
    end

    assert_redirected_to patients_path
  end

end
