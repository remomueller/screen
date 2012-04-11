require 'test_helper'

class PatientsControllerTest < ActionController::TestCase
  setup do
    @patient = patients(:one)
    login(users(:screener))
  end

  test "should get patient stickies" do
    app = proc do |env|
      [200, { 'Content-Type' => 'application/json' }, [ [{ id: 1, description: "6-month followup call", all_day: true, completed: false, tags: [ { id: 1, name: "Phone Call", color: '#aa00bb' } ] },
                                                         { id: 2, description: "8-month visit", all_day: true, due_date: "2011-04-11T14:45:00-04:00", completed: false, tags: [ { id: 2, name: "Visit", color: '#330077' } ] } ].to_json ]]
    end
    Artifice.activate_with(app) do
      post :stickies, id: patients(:with_subject_code), format: 'js'
    end
    assert_not_nil assigns(:stickies)
    # Can't assert this if the task tracker server is down or not set
    unless TASK_TRACKER_URL.blank? or TT_EMAIL.blank? or TT_PASSWORD.blank?
      assert_equal 1, assigns(:stickies).first['id']
      assert_equal "6-month followup call", assigns(:stickies).first['description']
      assert_equal ({ 'display' => 'No Date', 'id' => 'no_date' }), assigns(:stickies).first['month_year']
      assert_equal ({ 'display' => 'April 2011', 'id' => '042011' }), assigns(:stickies).last['month_year']
    end
    assert_template 'stickies'
    assert_response :success
  end

  test "should fail gracefully on unknown server response for task tracker stickies" do
    app = proc do |env|
      [500, { 'Content-Type' => 'text/html' }, [ "Internal Server Error" ]]
    end
    Artifice.activate_with(app) do
      post :stickies, id: patients(:with_subject_code), format: 'js'
    end
    assert_not_nil assigns(:stickies)
    assert_equal [], assigns(:stickies)
    assert_template 'stickies'
    assert_response :success
  end

  test "should not show patient stickies without subject code to subject handler" do
    login(users(:subject_handler))
    app = proc do |env|
      [200, { 'Content-Type' => 'application/json' }, [ [{ id: 1, description: "6-month followup call", all_day: true, completed: false, tags: [ { id: 1, name: "Phone Call", color: '#aa00bb' } ] },
                                                         { id: 2, description: "8-month visit", all_day: true, due_date: "2011-04-11T14:45:00-04:00", completed: false, tags: [ { id: 2, name: "Visit", color: '#330077' } ] } ].to_json ]]
    end
    Artifice.activate_with(app) do
      post :stickies, id: patients(:without_subject_code), format: 'js'
    end
    assert_response :success
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

  test "should get autocomplete" do
    get :index, autocomplete: 'true', term: '', format: 'js'
    assert_not_nil assigns(:patients)
    assert_template 'autocomplete'
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

  test "should create patient with mrn" do
    assert_difference('Patient.count') do
      post :create, patient: { mrn: '0123456789', first_name: 'FirstName', last_name: 'LastName', address1: 'Address 1', city: 'City', state: 'State', zip: 'zip', phone_home: '1112223333' }
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
    assert_equal ["can't be blank"], assigns(:patient).errors[:mrn]
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
    put :update, id: @patient, patient: { first_name: 'FirstNameUpdate', mrn: 'newmrn', subject_code: '' }
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
    assert_equal ["can't be blank"], assigns(:patient).errors[:mrn]
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
