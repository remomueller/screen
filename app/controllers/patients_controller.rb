class PatientsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

  def index
    # current_user.update_attribute :patients_per_page, params[:patients_per_page].to_i if params[:patients_per_page].to_i >= 10 and params[:patients_per_page].to_i <= 200
    patient_scope = Patient.current # current_user.all_viewable_patients
    patient_scope = patient_scope.with_mrn(params[:mrn]) unless params[:mrn].blank?

    @order = Patient.column_names.collect{|column_name| "patients.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "patients.id"
    patient_scope = patient_scope.order(@order)

    @patients = patient_scope.page(params[:page]).per(20) # (current_user.patients_per_page)
  end


  # # GET /patients
  # # GET /patients.json
  # def index
  #   @patients = Patient.all

  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.json { render json: @patients }
  #   end
  # end

  # GET /patients/1
  # GET /patients/1.json
  def show
    @patient = Patient.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @patient }
    end
  end

  # GET /patients/new
  # GET /patients/new.json
  def new
    @patient = Patient.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @patient }
    end
  end

  # GET /patients/1/edit
  def edit
    @patient = Patient.find(params[:id])
  end

  # POST /patients
  # POST /patients.json
  def create
    @patient = Patient.new(params[:patient])

    respond_to do |format|
      if @patient.save
        format.html { redirect_to @patient, notice: 'Patient was successfully created.' }
        format.json { render json: @patient, status: :created, location: @patient }
      else
        format.html { render action: "new" }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /patients/1
  # PUT /patients/1.json
  def update
    @patient = Patient.find(params[:id])

    respond_to do |format|
      if @patient.update_attributes(params[:patient])
        format.html { redirect_to @patient, notice: 'Patient was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1
  # DELETE /patients/1.json
  def destroy
    @patient = Patient.find(params[:id])
    @patient.destroy

    respond_to do |format|
      format.html { redirect_to patients_url }
      format.json { head :no_content }
    end
  end
end
