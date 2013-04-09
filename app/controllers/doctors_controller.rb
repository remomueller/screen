class DoctorsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_screener

  def index
    # current_user.update_column :doctors_per_page, params[:doctors_per_page].to_i if params[:doctors_per_page].to_i >= 10 and params[:doctors_per_page].to_i <= 200
    doctor_scope = Doctor.current # current_user.all_viewable_doctors
    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| doctor_scope = doctor_scope.search(search_term) }

    @order = scrub_order(Doctor, params[:order], 'doctors.name')
    doctor_scope = doctor_scope.order(@order)

    @doctor_count = doctor_scope.count
    @doctors = doctor_scope.page(params[:page]).per(40) # (current_user.doctors_per_page)
  end

  # GET /doctors/1
  # GET /doctors/1.json
  def show
    @doctor = Doctor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @doctor }
    end
  end

  # GET /doctors/new
  # GET /doctors/new.json
  def new
    @doctor = Doctor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @doctor }
    end
  end

  # GET /doctors/1/edit
  def edit
    @doctor = Doctor.find(params[:id])
  end

  # POST /doctors
  # POST /doctors.json
  def create
    @doctor = current_user.doctors.new(post_params)

    respond_to do |format|
      if @doctor.save
        format.html { redirect_to @doctor, notice: 'Doctor was successfully created.' }
        format.json { render json: @doctor, status: :created, location: @doctor }
      else
        format.html { render action: "new" }
        format.json { render json: @doctor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @doctor = Doctor.find(params[:id])

    if @doctor.update_attributes(post_params)
      notice = 'Doctor was successfully updated.'
      if params[:from] == 'prescreens'
        redirect_to prescreens_path, notice: notice
      else
        redirect_to @doctor, notice: notice
      end
    else
      render action: "edit"
    end
  end

  def destroy
    @doctor = Doctor.find(params[:id])
    @doctor.destroy

    redirect_to doctors_path, notice: 'Doctor was successfully deleted.'
  end

  private

  def post_params
    params[:doctor] ||= {}

    params[:doctor].slice(
      :name, :doctor_type, :status
    )
  end

end
