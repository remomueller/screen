require 'test_helper'

class VisitsControllerTest < ActionController::TestCase
  setup do
    @visit = visits(:one)
    login(users(:screener))
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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create visit" do
    assert_difference('Visit.count') do
      post :create, visit: @visit.attributes
    end

    assert_redirected_to visit_path(assigns(:visit))
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
    put :update, id: @visit, visit: @visit.attributes
    assert_redirected_to visit_path(assigns(:visit))
  end

  test "should not update visit with blank visit type" do
    put :update, id: @visit, visit: { patient_id: @visit.patient_id, visit_date: '02/16/2012', visit_type: '' }
    assert_not_nil assigns(:visit)
    assert assigns(:visit).errors.size > 0
    assert_equal ["can't be blank"], assigns(:visit).errors[:visit_type]
    assert_template 'edit'
  end

  test "should destroy visit" do
    assert_difference('Visit.current.count', -1) do
      delete :destroy, id: @visit
    end

    assert_redirected_to visits_path
  end
end