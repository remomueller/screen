class PatientsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_screener_or_subject_handler
  before_action :set_patient, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_patient, only: [ :show, :edit, :update, :destroy ]

  # GET /patients
  # GET /patients.json
  def index
    @order = scrub_order(Patient, params[:order], 'patients.id')
    @order = "priority DESC, " + @order if params[:priority_only] == '1'
    patient_scope = Patient.current.order(@order)

    if params[:mrn].to_s.split(',').size > 1
      patient_scope = patient_scope.where(subject_code: params[:mrn].to_s.gsub(/\s/, '').split(','))
    else
      params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
        patient_scope = patient_scope.with_mrn(term) unless term.blank?
      end
    end

    patient_scope = patient_scope.where("priority > 0") if params[:priority_only] == '1'
    patient_scope = patient_scope.subject_code_not_blank unless current_user.screener?
    patient_scope = patient_scope.with_priority_message(params[:priority_message]) unless params[:priority_message].blank?

    if params[:autocomplete] == 'true'
      @patients = patient_scope.page(params[:page]).per(10)
      render json: @patients.collect{|p| { value: p.phi_code(current_user).to_s, text: [p.phi_code(current_user), p.phi_name(current_user)].reject{ |i| i.blank? }.join(" - ") }}
    else
      @patients = patient_scope.page(params[:page]).per( 40 )
    end
  end

  # GET /patients/1
  # GET /patients/1.json
  def show
  end

  # GET /patients/new
  def new
    @patient = Patient.new
  end

  # GET /patients/1/edit
  def edit
  end

  # POST /patients
  # POST /patients.json
  def create
    @patient = current_user.patients.new(patient_params)

    respond_to do |format|
      if @patient.save
        format.html { redirect_to @patient, notice: 'Patient was successfully created.' }
        format.json { render action: 'show', status: :created, location: @patient }
      else
        format.html { render action: 'new' }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /patients/1
  # PUT /patients/1.json
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to @patient, notice: 'Patient was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1
  # DELETE /patients/1.json
  def destroy
    @patient.destroy

    respond_to do |format|
      format.html { redirect_to patients_path, notice: 'Patient was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    def set_patient
      patient = Patient.find_by_id(params[:id])
      @patient = patient if patient and patient.editable_by?(current_user)
    end

    def redirect_without_patient
      empty_response_or_root_path unless @patient
    end

    def patient_params
      params[:patient] ||= {}

      if current_user.access_phi?
        params.require(:patient).permit(
          :subject_code, :name_code, :priority, :priority_message,
          # PHI
          :mrn, :mrn_organization,
          :first_name, :last_name,
          :phone_home, :phone_day, :phone_alt,
          :sex, :age,
          :address1, :city, :state, :zip,
          :email
        )
      else
        params.require(:patient).permit(
          :subject_code, :name_code, :priority, :priority_message
        )
      end
    end

end
