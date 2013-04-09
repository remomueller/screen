class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_user, only: [ :show, :edit, :update, :destroy ]

  def index
    unless current_user.system_admin? or params[:format] == 'json'
      redirect_to root_path, alert: "You do not have sufficient privileges to access that page."
      return
    end

    @order = scrub_order(User, params[:order], 'users.current_sign_in_at DESC')
    @users = User.current.search(params[:search] || params[:q]).order(@order).page(params[:page]).per( 20 )

    respond_to do |format|
      format.html
      format.js
      format.json do # TODO: Put into jbuilder instead!
        render json: params[:q].to_s.split(',').collect{ |u| (u.strip.downcase == 'me') ? { name: current_user.name, id: current_user.name } : { name: u.strip.titleize, id: u.strip.titleize } } + @users.collect{ |u| { name: u.name, id: u.name } }
      end
    end
  end

  def show
  end

  # def new
  #   @user = User.new
  # end

  def edit
  end

  # # This is in registrations_controller.rb
  # def create
  # end

  def update
    original_status = @user.status
    if @user.update(user_params)
      UserMailer.status_activated(@user).deliver if Rails.env.production? and original_status != @user.status and @user.status == 'active'
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: 'User was successfully deleted.'
  end

  private

    def set_user
      @user = User.current.find_by_id(params[:id])
    end

    def redirect_without_user
      empty_response_or_root_path(users_path) unless @user
    end

    def user_params
      params[:user] ||= {}

      params.require(:user).permit(
        :first_name, :last_name, :email, :password, :password_confirmation, :system_admin, :screener, :subject_handler, :access_phi, :status
      )
    end

end
