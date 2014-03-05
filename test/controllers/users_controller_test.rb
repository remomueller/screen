require 'test_helper'

SimpleCov.command_name "test:controllers"

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:valid)
    @current_user = login(users(:admin))
  end

  test "should get index" do
    get :index
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should get index for autocomplete" do
    login(users(:valid))
    get :index, format: 'json'
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should not get index for non-system admin" do
    login(users(:valid))
    get :index
    assert_nil assigns(:users)
    assert_equal "You do not have sufficient privileges to access that page.", flash[:alert]
    assert_redirected_to root_path
  end

  # test "should get new" do
  #   get :new
  #   assert_not_nil assigns(:user)
  #   assert_response :success
  # end

  # test "should create user" do
  #   assert_difference('User.count') do
  #     post :create, user: @user.attributes
  #   end
  #
  #   assert_redirected_to user_path(assigns(:user))
  # end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: @user.attributes
    assert_redirected_to user_path(assigns(:user))
  end

  test "should update user and set user active" do
    put :update, id: users(:pending), user: { status: 'active', first_name: users(:pending).first_name, last_name: users(:pending).last_name, email: users(:pending).email, system_admin: false }
    assert_equal 'active', assigns(:user).status
    assert_redirected_to user_path(assigns(:user))
  end

  test "should update user and set user inactive" do
    put :update, id: users(:pending), user: { status: 'inactive', first_name: users(:pending).first_name, last_name: users(:pending).last_name, email: users(:pending).email, system_admin: false }
    assert_equal 'inactive', assigns(:user).status
    assert_redirected_to user_path(assigns(:user))
  end

  test "should not update user with blank name" do
    put :update, id: @user, user: { first_name: '', last_name: '' }
    assert_not_nil assigns(:user)
    assert_template 'edit'
  end

  test "should not update user with invalid id" do
    put :update, id: -1, user: @user.attributes
    assert_nil assigns(:user)
    assert_redirected_to users_path
  end

  test "should destroy user" do
    assert_difference('User.current.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
