class ClinicsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_screener
  before_action :set_clinic, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_clinic, only: [ :show, :edit, :update, :destroy ]

  # GET /clinics
  # GET /clinics.json
  def index
    @order = scrub_order(Clinic, params[:order], 'clinics.name')
    @clinics = Clinic.current.search(params[:search]).order(@order).page(params[:page]).per(40)
  end

  # GET /clinics/1
  # GET /clinics/1.json
  def show
  end

  # GET /clinics/new
  def new
    @clinic = Clinic.new
  end

  # GET /clinics/1/edit
  def edit
  end

  # POST /clinics
  # POST /clinics.json
  def create
    @clinic = current_user.clinics.new(clinic_params)

    respond_to do |format|
      if @clinic.save
        format.html { redirect_to @clinic, notice: 'Clinic was successfully created.' }
        format.json { render action: 'show', status: :created, location: @clinic }
      else
        format.html { render action: 'new' }
        format.json { render json: @clinic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /clinics/1
  # PUT /clinics/1.json
  def update
    respond_to do |format|
      if @clinic.update(clinic_params)
        format.html do
          url = (params[:from] == 'prescreens' ? prescreens_path : @clinic)
          redirect_to url, notice: 'Clinic was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @clinic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clinics/1
  # DELETE /clinics/1.json
  def destroy
    @clinic.destroy

    respond_to do |format|
      format.html { redirect_to clinics_path, notice: 'Clinic was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    def set_clinic
      @clinic = Clinic.find_by_id(params[:id])
    end

    def redirect_without_clinic
      empty_response_or_root_path(clinics_path) unless @clinic
    end

    def clinic_params
      params.require(:clinic).permit(
        :name, :status
      )
    end

end
