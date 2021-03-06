require 'test_helper'

class ClinicsControllerTest < ActionController::TestCase
  setup do
    @clinic = clinics(:one)
    login(users(:screener))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clinics)
  end

  test "should get index with js" do
    get :index, format: 'js', search: ''
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:clinics)
    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create clinic" do
    assert_difference('Clinic.count') do
      post :create, clinic: { name: 'ClinicThree' }
    end

    assert_not_nil assigns(:clinic)
    assert_equal users(:screener), assigns(:clinic).user
    assert_redirected_to clinic_path(assigns(:clinic))
  end

  test "should not create clinic with blank name" do
    assert_difference('Clinic.count', 0) do
      post :create, clinic: { name: '' }
    end

    assert_not_nil assigns(:clinic)
    assert assigns(:clinic).errors.size > 0
    assert_equal ["can't be blank"], assigns(:clinic).errors[:name]
    assert_template 'new'
  end

  test "should show clinic" do
    get :show, id: @clinic
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @clinic
    assert_response :success
  end

  test "should update clinic" do
    put :update, id: @clinic, clinic: { name: 'ClinicOneUpdate' }
    assert_redirected_to clinic_path(assigns(:clinic))
  end

  test "should update and whitelist clinic" do
    put :update, id: @clinic, clinic: { status: 'whitelist' }, from: 'prescreens'
    assert_not_nil assigns(:clinic)
    assert 'whitelist', assigns(:clinic).status
    assert_redirected_to prescreens_path
  end

  test "should update and blacklist clinic" do
    put :update, id: @clinic, clinic: { status: 'blacklist' }, from: 'prescreens'
    assert_not_nil assigns(:clinic)
    assert 'blacklist', assigns(:clinic).status
    assert_redirected_to prescreens_path
  end

  test "should not update clinic with blank name" do
    put :update, id: @clinic, clinic: { name: '' }
    assert_not_nil assigns(:clinic)
    assert assigns(:clinic).errors.size > 0
    assert_equal ["can't be blank"], assigns(:clinic).errors[:name]
    assert_template 'edit'
  end

  test "should destroy clinic" do
    assert_difference('Clinic.current.count', -1) do
      delete :destroy, id: @clinic
    end

    assert_redirected_to clinics_path
  end
end
