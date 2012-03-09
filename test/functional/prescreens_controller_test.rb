require 'test_helper'

class PrescreensControllerTest < ActionController::TestCase
  setup do
    @prescreen = prescreens(:one)
    login(users(:screener))
  end

  test "should get inline update" do
    post :inline_update, id: @prescreen, item: 'eligibility', update_value: 'eligible', format: 'js'

    assert_not_nil assigns(:prescreen)
    assert_equal 'eligible', assigns(:prescreen).eligibility
    assert_template 'inline_update'
    assert_response :success
  end

  test "should get inline update for risk factors" do
    post :inline_update, id: @prescreen, item: 'risk_factors', prescreen: { risk_factor_ids: []}, format: 'js'

    assert_not_nil assigns(:prescreen)
    assert_equal [], assigns(:prescreen).risk_factors.to_a
    assert_template 'inline_update'
    assert_response :success
  end

  test "should get bulk" do
    assert_difference('Prescreen.count', 19) do
      post :bulk, visit_date: "03/01/2012", tab_dump: File.read('test/support/prescreens/fake_bulk_import.txt')
    end

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

  test "should get new" do
    get :new
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

  test "should not create prescreen with invalid patient" do
    assert_difference('Prescreen.count', 0) do
      post :create, prescreen: { patient_id: '', clinic_id: @prescreen.clinic_id, doctor_id: @prescreen.doctor_id, visit_duration: 0, visit_units: 'minutes', eligibility: '', exclusion: '' }, visit_date: "03/01/2012", visit_time: "4:03pm"
    end

    assert_not_nil assigns(:prescreen)
    assert assigns(:prescreen).errors.size > 0
    assert_equal ["can't be blank"], assigns(:prescreen).errors[:patient_id]
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
    put :update, id: @prescreen, prescreen: @prescreen.attributes
    assert_redirected_to prescreen_path(assigns(:prescreen))
  end

  test "should not update prescreen with invalid patient" do
    put :update, id: @prescreen, prescreen:  { patient_id: '', clinic_id: @prescreen.clinic_id, doctor_id: @prescreen.doctor_id, visit_duration: 0, visit_units: 'minutes', eligibility: '', exclusion: '' }, visit_date: "03/01/2012", visit_time: "4:03pm"
    assert_not_nil assigns(:prescreen)
    assert assigns(:prescreen).errors.size > 0
    assert_equal ["can't be blank"], assigns(:prescreen).errors[:patient_id]
    assert_template 'edit'
  end

  test "should destroy prescreen" do
    assert_difference('Prescreen.current.count', -1) do
      delete :destroy, id: @prescreen
    end

    assert_redirected_to prescreens_path
  end
end
