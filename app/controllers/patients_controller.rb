class PatientsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener_or_subject_handler

  def inline_update
    @patient = Patient.find_by_id(params[:id])
    item = Patient::EDITABLES.include?(params[:item]) ? params[:item].to_sym : ''
    @patient.update_attribute(item, params[:update_value]) if @patient and not item.blank?
  end

  def index
    params[:mrn] ||= params[:term]
    # current_user.update_attribute :patients_per_page, params[:patients_per_page].to_i if params[:patients_per_page].to_i >= 10 and params[:patients_per_page].to_i <= 200
    patient_scope = Patient.current # current_user.all_viewable_patients
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      patient_scope = patient_scope.with_mrn(term) unless term.blank?
    end

    patient_scope = patient_scope.where("priority > 0") if params[:priority_only] == '1'
    patient_scope = patient_scope.subject_code_not_blank unless current_user.screener?

    patient_scope = patient_scope.with_priority_message(params[:priority_message]) unless params[:priority_message].blank?

    @order = Patient.column_names.collect{|column_name| "patients.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "patients.id"

    @order = "priority DESC, " + @order if params[:priority_only] == '1'

    patient_scope = patient_scope.order(@order)
    @patient_count = patient_scope.count

    if params[:autocomplete] == 'true'
      @patients = patient_scope.page(params[:page]).per(10)
      render 'autocomplete'
    else
      @patients = patient_scope.page(params[:page]).per(20) # (current_user.patients_per_page)
    end
  end

  def show
    @patient = Patient.find_by_id(params[:id])
    redirect_to root_path unless @patient and @patient.editable_by?(current_user)
  end

  def new
    @patient = Patient.new
  end

  def edit
    @patient = Patient.find_by_id(params[:id])
    redirect_to root_path unless @patient and @patient.editable_by?(current_user)
  end

  def create
    @patient = current_user.patients.new(params[:patient])

    if @patient.save
      redirect_to @patient, notice: 'Patient was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @patient = Patient.find_by_id(params[:id])

    if @patient and @patient.editable_by?(current_user)
      if @patient.update_attributes(params[:patient])
        redirect_to @patient, notice: 'Patient was successfully updated.'
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @patient = Patient.find_by_id(params[:id])
    if @patient and @patient.editable_by?(current_user)
      @patient.destroy
      redirect_to patients_path
    else
      redirect_to root_path
    end
  end
end
