class ClinicsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

  # GET /clinics
  # GET /clinics.json
  def index
    @clinics = Clinic.current

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clinics }
    end
  end

  # GET /clinics/1
  # GET /clinics/1.json
  def show
    @clinic = Clinic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @clinic }
    end
  end

  # GET /clinics/new
  # GET /clinics/new.json
  def new
    @clinic = Clinic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @clinic }
    end
  end

  # GET /clinics/1/edit
  def edit
    @clinic = Clinic.find(params[:id])
  end

  # POST /clinics
  # POST /clinics.json
  def create
    @clinic = Clinic.new(params[:clinic])

    respond_to do |format|
      if @clinic.save
        format.html { redirect_to @clinic, notice: 'Clinic was successfully created.' }
        format.json { render json: @clinic, status: :created, location: @clinic }
      else
        format.html { render action: "new" }
        format.json { render json: @clinic.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @clinic = Clinic.find(params[:id])

    if @clinic.update_attributes(params[:clinic])
      notice = 'Clinic was successfully updated.'
      if params[:from] == 'prescreens'
        redirect_to prescreens_path, notice: notice
      else
        redirect_to @clinic, notice: notice
      end
    else
      render action: "edit"
    end
  end

  # DELETE /clinics/1
  # DELETE /clinics/1.json
  def destroy
    @clinic = Clinic.find(params[:id])
    @clinic.destroy

    respond_to do |format|
      format.html { redirect_to clinics_url }
      format.json { head :no_content }
    end
  end
end
