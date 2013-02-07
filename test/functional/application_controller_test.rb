require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  setup do
    # Nothing
  end

  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get acceptable use policy" do
    get :use
    assert_response :success
  end

  test "should get dashboard" do
    login(users(:valid))
    get :dashboard
    assert_response :success
  end

end
