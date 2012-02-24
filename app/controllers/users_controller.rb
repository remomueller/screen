class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create]
  before_filter :check_system_admin, except: [:new, :create, :index, :show, :settings, :update_settings]
end
