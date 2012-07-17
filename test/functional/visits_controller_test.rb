require 'test_helper'

class VisitsControllerTest < ActionController::TestCase
  setup do
    @visit = visits(:one)
    login(users(:screener))
  end

  test "should get csv" do
    get :index, format: 'csv'
    assert_not_nil assigns(:csv_string)
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:visits)
  end

  test "should get index with js" do
    get :index, format: 'js', mrn: '0'
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:visits)
    assert_template 'index'
    assert_response :success
  end

  test "should get index with js for multiple subject codes" do
    get :index, format: 'js', mrn: ' S1234, S5678 '
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:visits)
    assert_equal ['S1234', 'S5678'], assigns(:visits).collect{|visit| visit.patient.subject_code}.uniq
    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new, patient_id: patients(:one)
    assert_response :success
  end

  test "should create visit" do
    assert_difference('Visit.count') do
      post :create, visit: { patient_id: @visit.patient_id, visit_date: '02/16/2012', visit_type: choices(:visit_type), outcome: choices(:visit_outcome) }
    end

    assert_not_nil assigns(:visit)
    assert_equal users(:screener), assigns(:visit).user
    assert_redirected_to patient_path(assigns(:visit).patient)
  end

  test "should not create visit with blank visit type" do
    assert_difference('Visit.count', 0) do
      post :create, visit: { patient_id: @visit.patient_id, visit_date: '02/16/2012', visit_type: '' }
    end

    assert_not_nil assigns(:visit)
    assert assigns(:visit).errors.size > 0
    assert_equal ["can't be blank"], assigns(:visit).errors[:visit_type]
    assert_template 'new'
  end

  test "should show visit" do
    get :show, id: @visit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @visit
    assert_response :success
  end

  test "should update visit" do
    put :update, id: @visit, visit: { patient_id: @visit.patient_id, visit_date: '02/16/2012', visit_type: choices(:visit_type), outcome: choices(:visit_outcome) }
    assert_redirected_to visit_path(assigns(:visit))
  end

  test "should not update visit with blank visit type" do
    put :update, id: @visit, visit: { patient_id: @visit.patient_id, visit_date: '02/16/2012', visit_type: '' }
    assert_not_nil assigns(:visit)
    assert assigns(:visit).errors.size > 0
    assert_equal ["can't be blank"], assigns(:visit).errors[:visit_type]
    assert_template 'edit'
  end

  test "should not update visit for patient without subject code as subject handler" do
    login(users(:subject_handler))
    put :update, id: visits(:without_subject_code), visit: { patient_id: visits(:without_subject_code).patient_id, visit_date: '02/16/2012', visit_type: choices(:visit_type), outcome: choices(:visit_outcome) }
    assert_redirected_to root_path
  end

  test "should destroy visit" do
    assert_difference('Visit.current.count', -1) do
      delete :destroy, id: @visit
    end

    assert_redirected_to visits_path
  end

  test "should not destroy visit for patient without subject code as subject handler" do
    login(users(:subject_handler))
    assert_difference('Visit.current.count', 0) do
      delete :destroy, id: visits(:without_subject_code)
    end

    assert_redirected_to root_path
  end

end
