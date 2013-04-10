class DoctorsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_screener
  before_action :set_doctor, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_doctor, only: [ :show, :edit, :update, :destroy ]

  # GET /doctors
  # GET /doctors.json
  def index
    @order = scrub_order(Doctor, params[:order], 'doctors.name')
    @doctors = Doctor.current.search(params[:search]).order(@order).page(params[:page]).per(40)
  end

  # GET /doctors/1
  # GET /doctors/1.json
  def show
  end

  # GET /doctors/new
  def new
    @doctor = Doctor.new
  end

  # GET /doctors/1/edit
  def edit
  end

  # POST /doctors
  # POST /doctors.json
  def create
    @doctor = current_user.doctors.new(doctor_params)

    respond_to do |format|
      if @doctor.save
        format.html { redirect_to @doctor, notice: 'Doctor was successfully created.' }
        format.json { render action: 'show', status: :created, location: @doctor }
      else
        format.html { render action: 'new' }
        format.json { render json: @doctor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /doctors/1
  # PUT /doctors/1.json
  def update
    respond_to do |format|
      if @doctor.update(doctor_params)
        format.html do
          url = (params[:from] == 'prescreens' ? prescreens_path : @doctor)
          redirect_to url, notice: 'Doctor was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @doctor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /doctors/1
  # DELETE /doctors/1.json
  def destroy
    @doctor.destroy

    respond_to do |format|
      format.html { redirect_to doctors_path, notice: 'Doctor was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    def set_doctor
      @doctor = Doctor.find_by_id(params[:id])
    end

    def redirect_without_doctor
      empty_response_or_root_path(doctors_path) unless @doctor
    end

    def doctor_params
      params.require(:doctor).permit(
        :name, :doctor_type, :status
      )
    end

end
