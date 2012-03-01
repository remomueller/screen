require 'test_helper'

class ChoicesControllerTest < ActionController::TestCase
  setup do
    @choice = choices(:one)
    login(users(:admin))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:choices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create choice" do
    assert_difference('Choice.count') do
      post :create, choice: { category: 'exclusion', name: 'Second Choice' }
    end

    assert_redirected_to choice_path(assigns(:choice))
  end

  test "should not create choice with blank name" do
    assert_difference('Choice.count', 0) do
      post :create, choice: { category: 'exclusion', name: '' }
    end

    assert_not_nil assigns(:choice)
    assert assigns(:choice).errors.size > 0
    assert_equal ["can't be blank"], assigns(:choice).errors[:name]
    assert_template 'new'
  end

  test "should show choice" do
    get :show, id: @choice
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @choice
    assert_response :success
  end

  test "should update choice" do
    put :update, id: @choice, choice: { category: 'exclusion', name: 'Updated Name' }
    assert_redirected_to choice_path(assigns(:choice))
  end

  test "should not update choice with blank name" do
    put :update, id: @choice, choice: { category: 'exclusion', name: '' }
    assert_not_nil assigns(:choice)
    assert assigns(:choice).errors.size > 0
    assert_equal ["can't be blank"], assigns(:choice).errors[:name]
    assert_template 'edit'
  end

  test "should destroy choice" do
    assert_difference('Choice.current.count', -1) do
      delete :destroy, id: @choice
    end

    assert_redirected_to choices_path
  end
end
