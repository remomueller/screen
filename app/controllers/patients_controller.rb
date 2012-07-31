class PatientsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener_or_subject_handler

  def inline_update
    @patient = Patient.find_by_id(params[:id])
    item = Patient::EDITABLES.include?(params[:item]) ? params[:item].to_sym : ''
    @patient.update_attributes item => params[:update_value] if @patient and not item.blank?
  end

  def index
    params[:mrn] ||= params[:term]
    # current_user.update_column :patients_per_page, params[:patients_per_page].to_i if params[:patients_per_page].to_i >= 10 and params[:patients_per_page].to_i <= 200
    patient_scope = Patient.current # current_user.all_viewable_patients

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

    @order = scrub_order(Patient, params[:order], 'patients.id')
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

  def stickies
    @patient = Patient.find_by_id(params[:id])
    if @patient and not @patient.subject_code.blank?
      current_user.update_attributes task_tracker_screen_token: params[:screen_token] unless params[:screen_token].blank?
      result_hash = send_message("stickies.json", { 'api_token' => 'screen_token', 'screen_token' => current_user.task_tracker_screen_token, 'unnassigned' => '1', 'editable_only' => '0', 'status[]' => ['completed', 'planned'], 'tag_filter' => 'any', 'tag_names[]' => ['Phone Call', 'Visit'], 'search' => @patient.subject_code, 'order' => 'stickies.due_date DESC' }, "get")
      stickies = result_hash[:result].blank? ? [] : ActiveSupport::JSON.decode(result_hash[:result])
      @stickies = []
      stickies.each do |s|
        s['due_date'] = Time.parse(s['due_date']) rescue ''
        s['month_year'] = if s['due_date'].blank?
          { display: 'No Date', id: 'no_date' }
        else
          { display: s['due_date'].strftime('%B') + (s['due_date'].year == Date.today.year ? "" : " #{s['due_date'].year}" ), id: s['due_date'].strftime("%m%Y") }
        end
        @stickies << s
      end
    else
      render nothing: true
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
    @patient = current_user.patients.new(post_params)

    if @patient.save
      redirect_to @patient, notice: 'Patient was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @patient = Patient.find_by_id(params[:id])

    if @patient and @patient.editable_by?(current_user)
      if @patient.update_attributes(post_params)
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
      redirect_to patients_path, notice: 'Patient was successfully deleted.'
    else
      redirect_to root_path
    end
  end

  private

  def post_params
    params[:patient] ||= {}

    if current_user.access_phi?
      params[:patient].slice(
        :subject_code, :name_code, :priority, :priority_message,
        # PHI
        :mrn, :first_name, :last_name,
        :phone_home, :phone_day, :phone_alt,
        :sex, :age,
        :address1, :city, :state, :zip
      )
    else
      params[:patient].slice(
        :subject_code, :name_code, :priority, :priority_message
      )
    end
  end


end
