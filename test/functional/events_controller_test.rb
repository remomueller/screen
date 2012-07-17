require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = events(:one)
    login(users(:screener))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get index with js" do
    get :index, format: 'js'
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:events)
    assert_template 'index'
    assert_response :success
  end

  test "should get index with js and mrn" do
    get :index, format: 'js', mrn: '0'
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:events)
    assert_template 'index'
    assert_response :success
  end

  test "should get index with js for multiple subject codes" do
    get :index, format: 'js', mrn: ' S1234, S5678 '
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:events)
    assert_equal ['S1234', 'S5678'], assigns(:events).collect{|event| event.patient.subject_code}.uniq.sort
    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new, patient_id: patients(:one)
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, event: @event.attributes
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should not create event with invalid patient" do
    assert_difference('Event.count', 0) do
      post :create, event: { patient_id: '', class_name: '', class_id: '' }
    end

    assert_not_nil assigns(:event)
    assert assigns(:event).errors.size > 0
    assert_equal ["can't be blank"], assigns(:event).errors[:patient_id]
    assert_template 'new'
  end

  test "should show event" do
    get :show, id: @event
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event
    assert_response :success
  end

  test "should update event" do
    put :update, id: @event, event: @event.attributes
    assert_redirected_to event_path(assigns(:event))
  end

  test "should not update event with invalid patient" do
    put :update, id: @event, event: { patient_id: '' }
    assert_not_nil assigns(:event)
    assert assigns(:event).errors.size > 0
    assert_equal ["can't be blank"], assigns(:event).errors[:patient_id]
    assert_template 'edit'
  end

  test "should destroy event" do
    assert_difference('Event.current.count', -1) do
      delete :destroy, id: @event
    end

    assert_redirected_to events_path
  end
end
