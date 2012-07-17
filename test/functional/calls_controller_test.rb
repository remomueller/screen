require 'test_helper'
require 'artifice'

class CallsControllerTest < ActionController::TestCase
  setup do
    @call = calls(:one)
    login(users(:screener))
  end

  test "should get task tracker templates" do
    app = proc do |env|
      [200, { 'Content-Type' => 'application/json' }, [ [{ id: 1, full_name: "Template One - Project One" }].to_json ]]
    end
    Artifice.activate_with(app) do
      post :task_tracker_templates, format: 'js'
    end
    assert_not_nil assigns(:templates)
    # Can't assert this if the task tracker server is down or not set
    unless TASK_TRACKER_URL.blank? or TT_EMAIL.blank? or TT_PASSWORD.blank?
      assert_equal 1, assigns(:templates).first['id']
      assert_equal "Template One - Project One", assigns(:templates).first['full_name']
    end
    assert_template 'task_tracker_templates'
    assert_response :success
  end

  test "should get task tracker templates with redirect" do
    app = proc do |env|
      if env['PATH_INFO'].split('/').last == 'templates.json'
        # Temporary Redirect
        [307, { 'Content-Type' => 'application/json', 'Location' => 'http://localhost/new/templates_new_location.json' }, [ [{ id: 1, full_name: "Template One - Project One" }].to_json ]]
      else
        [200, { 'Content-Type' => 'application/json' }, [ [{ id: 1, full_name: "Template One - Project One" }].to_json ]]
      end
    end
    Artifice.activate_with(app) do
      post :task_tracker_templates, format: 'js'
    end
    assert_not_nil assigns(:templates)
    # Can't assert this if the task tracker server is down or not set
    unless TASK_TRACKER_URL.blank? or TT_EMAIL.blank? or TT_PASSWORD.blank?
      assert_equal 1, assigns(:templates).first['id']
      assert_equal "Template One - Project One", assigns(:templates).first['full_name']
    end
    assert_template 'task_tracker_templates'
    assert_response :success
  end

  test "should fail gracefully on unknown server response for task tracker templates" do
    app = proc do |env|
      [500, { 'Content-Type' => 'text/html' }, [ "Internal Server Error" ]]
    end
    Artifice.activate_with(app) do
      post :task_tracker_templates, format: 'js'
    end
    assert_not_nil assigns(:templates)
    assert_equal [], assigns(:templates)
    assert_template 'task_tracker_templates'
    assert_response :success
  end

  test "should recover from incorrect service url for task tracker templates" do
    app = proc do |env|
      if env['PATH_INFO'].split('/').last == 'templates.json'
        # Temporary Redirect to an incorrect URL
        [307, { 'Content-Type' => 'application/json', 'Location' => 'not\\a\\uri' }, [ [{ id: 1, full_name: "Template One - Project One" }].to_json ]]
      else
        [200, { 'Content-Type' => 'application/json' }, [ [{ id: 1, full_name: "Template One - Project One" }].to_json ]]
      end
    end
    Artifice.activate_with(app) do
      post :task_tracker_templates, format: 'js'
    end
    assert_not_nil assigns(:templates)
    assert_equal [], assigns(:templates)
    assert_template 'task_tracker_templates'
    assert_response :success
  end

  test "should get csv" do
    get :index, format: 'csv'
    assert_not_nil assigns(:csv_string)
    assert_response :success
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

  test "should get index with js for multiple subject codes" do
    get :index, format: 'js', mrn: ' S1234, S5678 '
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:calls)
    assert_equal ['S1234', 'S5678'], assigns(:calls).collect{|call| call.patient.subject_code}.uniq.sort
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
    assert_equal Time.local(2012, 2, 28, 17, 45, 0), assigns(:call).call_time
    assert_redirected_to patient_path(assigns(:call).patient)
  end

  test "should create call using template and assigning group from task tracker" do
    app = proc do |env|
      [200, { 'Content-Type' => 'application/json' }, [ { id: 1, description: "Group Description", template_id: 5 }.to_json ]]
    end
    Artifice.activate_with(app) do
      assert_difference('Call.count') do
        post :create, call: { patient_id: @call.patient_id, call_type: choices(:call_type), direction: 'incoming', tt_template_id: 1 }, call_date: "02/28/2012", call_time: "5:45pm", initial_due_date: "03/28/2012"
      end
    end

    assert_not_nil assigns(:group)
    # Can't assert this if the task tracker server is down or not set
    unless TASK_TRACKER_URL.blank? or TT_EMAIL.blank? or TT_PASSWORD.blank?
      assert_equal 1, assigns(:group)['id']
      assert_equal 5, assigns(:group)['template_id']
    end
    assert_not_nil assigns(:call)
    assert_equal users(:screener), assigns(:call).user
    assert_equal Time.local(2012, 2, 28, 17, 45, 0), assigns(:call).call_time
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

  test "should show group for call" do
    post :show_group, id: @call, format: 'js'
    assert_not_nil assigns(:call)
    assert_not_nil assigns(:group)
    assert_template 'show_group'
    assert_response :success
  end

  test "should not show group for invalid call" do
    post :show_group, id: -1, format: 'js'
    assert_nil assigns(:group)
    assert_nil assigns(:call)
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @call
    assert_response :success
  end

  test "should update call" do
    put :update, id: @call, call: { patient_id: @call.patient_id, call_type: choices(:call_type), direction: 'incoming' }, call_date: "02/28/2012", call_time: "5:50pm"
    assert_not_nil assigns(:call)
    assert_equal Time.local(2012, 2, 28, 17, 50, 0), assigns(:call).call_time
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
