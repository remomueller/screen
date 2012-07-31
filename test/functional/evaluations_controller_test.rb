require 'test_helper'

class EvaluationsControllerTest < ActionController::TestCase
  setup do
    @evaluation = evaluations(:one)
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
    assert_not_nil assigns(:evaluations)
  end

  test "should get index with js" do
    get :index, format: 'js', mrn: '0'
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:evaluations)
    assert_template 'index'
    assert_response :success
  end

  test "should get index with js for multiple subject codes" do
    get :index, format: 'js', mrn: ' S1234, S5678 '
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:evaluations)
    assert_equal ['S1234', 'S5678'], assigns(:evaluations).collect{|evaluation| evaluation.patient.subject_code}.uniq.sort
    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new, patient_id: patients(:one)
    assert_response :success
  end

  test "should create evaluation" do
    assert_difference('Evaluation.count') do
      post :create, evaluation: { patient_id: @evaluation.patient_id, administration_date: '02/16/2012', administration_type: choices(:four), evaluation_type: choices(:five) }
    end

    assert_not_nil assigns(:evaluation)
    assert_equal users(:screener), assigns(:evaluation).user
    assert_redirected_to patient_path(assigns(:evaluation).patient)
  end

  test "should create evaluation with receipt date and scored date" do
    assert_difference('Event.count', 3) do
      assert_difference('Evaluation.count') do
        post :create, evaluation: { patient_id: @evaluation.patient_id, administration_date: '02/16/2012', receipt_date: '07/31/2012', scored_date: '08/01/2012', administration_type: choices(:four), evaluation_type: choices(:five) }
      end
    end

    assert_not_nil assigns(:evaluation)
    assert_equal users(:screener), assigns(:evaluation).user
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
    put :update, id: @evaluation, evaluation: { patient_id: @evaluation.patient_id, administration_date: '02/20/2012', administration_type: choices(:four), evaluation_type: choices(:five) }
    assert_not_nil assigns(:evaluation)
    assert_equal Date.parse('2012-02-20'), assigns(:evaluation).administration_date
    assert_redirected_to evaluation_path(assigns(:evaluation))
  end

  test "should not update evaluation for patient without subject code as subject handler" do
    login(users(:subject_handler))
    put :update, id: evaluations(:without_subject_code), evaluation: { patient_id: evaluations(:without_subject_code).patient_id, administration_date: '02/20/2012', administration_type: choices(:four), evaluation_type: choices(:five) }
    assert_redirected_to root_path
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

  test "should not destroy evaluation for patient without subject code as subject handler" do
    login(users(:subject_handler))
    assert_difference('Evaluation.current.count', 0) do
      delete :destroy, id: evaluations(:without_subject_code)
    end

    assert_redirected_to root_path
  end
end
