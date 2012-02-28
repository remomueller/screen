class PatientsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

  def inline_update
    @patient = Patient.find_by_id(params[:id])
    item = Patient::EDITABLES.include?(params[:item]) ? params[:item].to_sym : ''
    @patient.update_attribute(item, params[:update_value]) if @patient and not item.blank?
  end

  def index
    # current_user.update_attribute :patients_per_page, params[:patients_per_page].to_i if params[:patients_per_page].to_i >= 10 and params[:patients_per_page].to_i <= 200
    patient_scope = Patient.current # current_user.all_viewable_patients
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      patient_scope = patient_scope.with_mrn(term) unless term.blank?
    end

    @order = Patient.column_names.collect{|column_name| "patients.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "patients.id"
    patient_scope = patient_scope.order(@order)

    @patients = patient_scope.page(params[:page]).per(20) # (current_user.patients_per_page)
  end

  def show
    @patient = Patient.find(params[:id])

  end

  def new
    @patient = Patient.new
  end

  def edit
    @patient = Patient.find(params[:id])
  end

  def create
    @patient = Patient.new(params[:patient])

    if @patient.save
      redirect_to @patient, notice: 'Patient was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @patient = Patient.find(params[:id])

    if @patient.update_attributes(params[:patient])
      redirect_to @patient, notice: 'Patient was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @patient = Patient.find(params[:id])
    @patient.destroy

    redirect_to patients_path
  end
end
