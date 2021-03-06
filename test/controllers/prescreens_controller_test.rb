require 'test_helper'

class PrescreensControllerTest < ActionController::TestCase
  setup do
    @prescreen = prescreens(:one)
    login(users(:screener))
  end

  test "should get bulk" do
    get :bulk
    assert_response :success
  end

  test "should import prescreens" do
    assert_difference('Prescreen.count', 20) do
      post :import, visit_date: "03/01/2012", tab_dump: File.read('test/support/prescreens/fake_bulk_import.txt')
    end

    assert_redirected_to prescreens_path
  end

  test "should import prescreens and zero-pad MRNs" do
    assert_difference('Prescreen.count', 20) do
      post :import, visit_date: "03/01/2012", tab_dump: File.read('test/support/prescreens/fake_bulk_import.txt')
    end

    assert_equal 0, Patient.where(mrn: '16').count
    assert_equal 1, Patient.where(mrn: '00000016').count

    assert_redirected_to prescreens_path
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:prescreens)
  end

  test "should get index with js" do
    get :index, format: 'js', mrn: '0'
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:prescreens)
    assert_template 'index'
    assert_response :success
  end

  test "should get index with js for multiple subject codes" do
    get :index, format: 'js', mrn: ' S1234, S5678 '
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:prescreens)
    assert_equal ['S1234', 'S5678'], assigns(:prescreens).collect{|prescreen| prescreen.patient.subject_code}.uniq.sort
    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new, patient_id: patients(:one)
    assert_response :success
  end

  test "should create prescreen" do
    assert_difference('Prescreen.count') do
      post :create, prescreen: { patient_id: @prescreen.patient_id, clinic_id: @prescreen.clinic_id, doctor_id: @prescreen.doctor_id, visit_duration: 0, visit_units: 'minutes', eligibility: '', exclusion: '' }, visit_date: "03/09/2012", visit_time: "10:58am"
    end

    assert_not_nil assigns(:prescreen)
    assert_equal users(:screener), assigns(:prescreen).user
    assert_redirected_to patient_path(assigns(:prescreen).patient)
  end

  test "should create prescreen and event" do
    assert_difference('Event.count') do
      assert_difference('Prescreen.count') do
        post :create, prescreen: { patient_id: @prescreen.patient_id, clinic_id: @prescreen.clinic_id, doctor_id: @prescreen.doctor_id, visit_duration: 0, visit_units: 'minutes', eligibility: '', exclusion: '' }, visit_date: "03/09/2012", visit_time: "10:58am"
      end
    end

    assert_not_nil assigns(:prescreen)
    assert_equal users(:screener), assigns(:prescreen).user
    assert_redirected_to patient_path(assigns(:prescreen).patient)
  end

  test "should create prescreen with a two digit year" do
    assert_difference('Prescreen.count') do
      post :create, prescreen: { patient_id: @prescreen.patient_id, clinic_id: @prescreen.clinic_id, doctor_id: @prescreen.doctor_id }, visit_date: "04/19/12", visit_time: "9:48am"
    end

    assert_not_nil assigns(:prescreen)
    assert_equal users(:screener), assigns(:prescreen).user
    assert_equal Time.local(2012, 4, 19, 9, 48, 0), assigns(:prescreen).visit_at
    assert_redirected_to patient_path(assigns(:prescreen).patient)
  end

  test "should not create prescreen with invalid patient" do
    assert_difference('Prescreen.count', 0) do
      post :create, prescreen: { patient_id: '', clinic_id: @prescreen.clinic_id, doctor_id: @prescreen.doctor_id, visit_duration: 0, visit_units: 'minutes', eligibility: '', exclusion: '' }, visit_date: "03/01/2012", visit_time: "4:03pm"
    end

    assert_not_nil assigns(:prescreen)
    assert assigns(:prescreen).errors.size > 0
    assert_equal ["can't be blank"], assigns(:prescreen).errors[:patient_id]
    assert_template 'new'
  end

  test "should not create prescreen with blank visit at" do
    assert_difference('Prescreen.count', 0) do
      post :create, prescreen: { patient_id: @prescreen.patient_id, clinic_id: @prescreen.clinic_id, doctor_id: @prescreen.doctor_id, visit_duration: 0, visit_units: 'minutes', eligibility: '', exclusion: '' }, visit_date: "", visit_time: ""
    end

    assert_not_nil assigns(:prescreen)
    assert assigns(:prescreen).errors.size > 0
    assert_equal ["date and time can't be blank"], assigns(:prescreen).errors[:visit_at]
    assert_template 'new'
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
    put :update, id: @prescreen, prescreen: @prescreen.attributes, visit_date: "04/19/2012", visit_time: "9:26am"
    assert_redirected_to prescreen_path(assigns(:prescreen))
  end

  test "should update prescreen with two-digit year" do
    put :update, id: @prescreen, prescreen: @prescreen.attributes, visit_date: "04/19/12", visit_time: "9:26am"
    assert_not_nil assigns(:prescreen)
    assert_equal Time.local(2012, 4, 19, 9, 26, 0), assigns(:prescreen).visit_at
    assert_redirected_to prescreen_path(assigns(:prescreen))
  end

  test "should not update prescreen for patient without subject code as subject handler" do
    login(users(:subject_handler))
    put :update, id: prescreens(:without_subject_code), prescreen: prescreens(:without_subject_code).attributes
    assert_redirected_to root_path
  end

  test "should not update prescreen with invalid patient" do
    put :update, id: @prescreen, prescreen:  { patient_id: '', clinic_id: @prescreen.clinic_id, doctor_id: @prescreen.doctor_id, visit_duration: 0, visit_units: 'minutes', eligibility: '', exclusion: '' }, visit_date: "03/01/2012", visit_time: "4:03pm"
    assert_not_nil assigns(:prescreen)
    assert assigns(:prescreen).errors.size > 0
    assert_equal ["can't be blank"], assigns(:prescreen).errors[:patient_id]
    assert_template 'edit'
  end

  test "should not update prescreen with blank visit at" do
    put :update, id: @prescreen, prescreen:  { patient_id: @prescreen.patient_id, clinic_id: @prescreen.clinic_id, doctor_id: @prescreen.doctor_id, visit_duration: 0, visit_units: 'minutes', eligibility: '', exclusion: '' }, visit_date: "", visit_time: ""
    assert_not_nil assigns(:prescreen)
    assert assigns(:prescreen).errors.size > 0
    assert_equal ["date and time can't be blank"], assigns(:prescreen).errors[:visit_at]
    assert_template 'edit'
  end

  test "should destroy prescreen" do
    assert_difference('Prescreen.current.count', -1) do
      delete :destroy, id: @prescreen
    end

    assert_redirected_to prescreens_path
  end

  test "should not destroy prescreen for patient without subject code as subject handler" do
    login(users(:subject_handler))
    assert_difference('Prescreen.current.count', 0) do
      delete :destroy, id: prescreens(:without_subject_code)
    end

    assert_redirected_to root_path
  end
end
