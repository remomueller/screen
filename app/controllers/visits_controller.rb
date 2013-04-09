class VisitsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_screener_or_subject_handler

  def index
    # current_user.update_column :visits_per_page, params[:visits_per_page].to_i if params[:visits_per_page].to_i >= 10 and params[:visits_per_page].to_i <= 200
    visit_scope = Visit.current # current_user.all_viewable_visits

    if params[:mrn].to_s.split(',').size > 1
      visit_scope = visit_scope.with_subject_code(params[:mrn].to_s.gsub(/\s/, '').split(','))
    else
      params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
        visit_scope = visit_scope.with_mrn(term) unless term.blank?
      end
    end

    visit_scope = visit_scope.subject_code_not_blank unless current_user.screener?

    @visit_after = parse_date(params[:visit_after])
    @visit_before = parse_date(params[:visit_before])

    visit_scope = visit_scope.visit_before(@visit_before) unless @visit_before.blank?
    visit_scope = visit_scope.visit_after(@visit_after) unless @visit_after.blank?
    visit_scope = visit_scope.where( outcome: params[:outcome] ) unless params[:outcome].blank?
    visit_scope = visit_scope.where( visit_type: params[:visit_type] ) unless params[:visit_type].blank?

    @order = scrub_order(Visit, params[:order], 'visits.patient_id')
    visit_scope = visit_scope.order(@order)

    if params[:format] == 'csv'
      generate_csv(visit_scope)
      return
    elsif params[:format] == 'contact_csv'
      generate_contact_csv(visit_scope)
      return
    end

    @visit_count = visit_scope.count
    @visits = visit_scope.page(params[:page]).per(20) # (current_user.visits_per_page)
  end

  def show
    @visit = Visit.find_by_id(params[:id])
    redirect_to root_path unless @visit and @visit.patient.editable_by?(current_user)
  end

  def new
    @visit = Visit.new(patient_id: params[:patient_id])
    redirect_to root_path unless @visit and @visit.patient.editable_by?(current_user)
  end

  def edit
    @visit = Visit.find_by_id(params[:id])
    redirect_to root_path unless @visit and @visit.patient.editable_by?(current_user)
  end

  def create
    @visit = current_user.visits.new(post_params)

    if @visit.save
      redirect_to @visit.patient, notice: 'Visit was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @visit = Visit.find_by_id(params[:id])

    if @visit and @visit.patient.editable_by?(current_user)
      if @visit.update_attributes(post_params)
        redirect_to @visit, notice: 'Visit was successfully updated.'
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @visit = Visit.find_by_id(params[:id])
    if @visit and @visit.patient.editable_by?(current_user)
      @visit.destroy
      redirect_to visits_path, notice: 'Visit was successfully deleted.'
    else
      redirect_to root_path
    end
  end

  private

  def generate_csv(visit_scope)
    @csv_string = CSV.generate do |csv|
      csv << ["Patient ID", "Subject Code", "Visit Type", "Visit Date", "Outcome", "Comments"]
      visit_scope.each do |visit|
        csv << [
          visit.patient.id,
          visit.patient.subject_code,
          visit.visit_type_name,
          visit.visit_date.strftime("%Y-%m-%d"),
          visit.outcome_name,
          visit.comments
        ]
      end
    end
    send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                          disposition: "attachment; filename=\"Visits #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
  end

  def generate_contact_csv(visit_scope)
    @csv_string = CSV.generate do |csv|
      csv << ["Visit Date", "Subject Code", "Last Name", "First Name", "Address1", "City", "State", "Zip Code", "Home Phone", "Day Phone"]
      visit_scope.each do |visit|
        csv << [
          visit.visit_date.strftime("%Y-%m-%d"),
          visit.patient.subject_code,
          visit.patient.phi_last_name(current_user),
          visit.patient.phi_first_name(current_user),
          visit.patient.phi_address1(current_user),
          visit.patient.phi_city(current_user),
          visit.patient.phi_state(current_user),
          visit.patient.phi_zip(current_user),
          pretty_phone(visit.patient.phi_phone_home(current_user)),
          pretty_phone(visit.patient.phi_phone_day(current_user))
        ]
      end
    end
    send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                          disposition: "attachment; filename=\"Visits Contact List #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
  end


  def post_params
    params[:visit] ||= {}

    params[:visit][:visit_date] = parse_date(params[:visit][:visit_date])

    params[:visit].slice(
      :patient_id, :visit_type, :visit_date, :outcome, :comments
    )
  end


end
