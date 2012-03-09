require 'test_helper'

class EvaluationsControllerTest < ActionController::TestCase
  setup do
    @evaluation = evaluations(:one)
    login(users(:screener))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:evaluations)
  end

  test "should get index with js" do
    get :index, format: 'js', mrn: '0'
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:evaluations)
    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create evaluation" do
    assert_difference('Evaluation.count') do
      post :create, evaluation: { patient_id: @evaluation.patient_id, administration_date: '02/16/2012', administration_type: choices(:four), evaluation_type: choices(:five) }
    end

    assert_redirected_to patient_path(assigns(:evaluation).patient)
  end

  test "should not create evaluation with blank administration type" do
    assert_difference('Evaluation.count', 0) do
      post :create, evaluation: { patient_id: @evaluation.patient_id, administration_date: '02/16/2012', administration_type: '' }
    end

    assert_not_nil assigns(:evaluation)
    assert assigns(:evaluation).errors.size > 0
    assert_equal ["can't be blank"], assigns(:evaluation).errors[:administration_type]
    assert_template 'new'
  end

  test "should show evaluation" do
    get :show, id: @evaluation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @evaluation
    assert_response :success
  end

  test "should update evaluation" do
    put :update, id: @evaluation, evalution: { patient_id: @evaluation.patient_id, administration_date: '02/20/2012', administration_type: choices(:four), evaluation_type: choices(:five) }
    assert_redirected_to evaluation_path(assigns(:evaluation))
  end

  test "should not update evaluation with blank administration type" do
    put :update, id: @evaluation, evaluation: { patient_id: @evaluation.patient_id, administration_date: '02/16/2012', administration_type: '' }
    assert_not_nil assigns(:evaluation)
    assert assigns(:evaluation).errors.size > 0
    assert_equal ["can't be blank"], assigns(:evaluation).errors[:administration_type]
    assert_template 'edit'
  end

  test "should destroy evaluation" do
    assert_difference('Evaluation.current.count', -1) do
      delete :destroy, id: @evaluation
    end

    assert_redirected_to evaluations_path
  end
end
