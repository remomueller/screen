require 'test_helper'

class MailingsControllerTest < ActionController::TestCase
  setup do
    @mailing = mailings(:one)
    login(users(:screener))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mailings)
  end

  test "should get index with js" do
    get :index, format: 'js', mrn: '0'
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:mailings)
    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mailing" do
    assert_difference('Mailing.count') do
      post :create, mailing: { patient_id: @mailing.patient_id, sent_date: '02/16/2012', doctor_id: @mailing.doctor_id }
    end

    assert_redirected_to patient_path(assigns(:mailing).patient)
  end

  test "should not create mailing with invalid doctor" do
    assert_difference('Mailing.count', 0) do
      post :create, mailing: { patient_id: @mailing.patient_id, sent_date: '02/16/2012', doctor_id: '' }
    end

    assert_not_nil assigns(:mailing)
    assert assigns(:mailing).errors.size > 0
    assert_equal ["can't be blank"], assigns(:mailing).errors[:doctor_id]
    assert_template 'new'
  end

  test "should show mailing" do
    get :show, id: @mailing
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mailing
    assert_response :success
  end

  test "should update mailing" do
    put :update, id: @mailing, mailing: { patient_id: @mailing.patient_id, sent_date: '02/16/2012' }
    assert_redirected_to mailing_path(assigns(:mailing))
  end

  test "should not update mailing with invalid doctor" do
    put :update, id: @mailing, mailing: { patient_id: @mailing.patient_id, sent_date: '02/16/2012', doctor_id: '' }
    assert_not_nil assigns(:mailing)
    assert assigns(:mailing).errors.size > 0
    assert_equal ["can't be blank"], assigns(:mailing).errors[:doctor_id]
    assert_template 'edit'
  end

  test "should destroy mailing" do
    assert_difference('Mailing.current.count', -1) do
      delete :destroy, id: @mailing
    end

    assert_redirected_to mailings_path
  end
end
