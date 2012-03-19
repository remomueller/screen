class VisitsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener_or_subject_handler

  def index
    # current_user.update_attribute :visits_per_page, params[:visits_per_page].to_i if params[:visits_per_page].to_i >= 10 and params[:visits_per_page].to_i <= 200
    visit_scope = Visit.current # current_user.all_viewable_visits
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      visit_scope = visit_scope.with_mrn(term) unless term.blank?
    end

    visit_scope = visit_scope.subject_code_not_blank unless current_user.screener?

    @order = Visit.column_names.collect{|column_name| "visits.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "visits.id"
    visit_scope = visit_scope.order(@order)

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
    params[:visit][:visit_date] = Date.strptime(params[:visit][:visit_date], "%m/%d/%Y") if params[:visit] and not params[:visit][:visit_date].blank?

    @visit = current_user.visits.new(params[:visit])

    if @visit.save
      redirect_to @visit.patient, notice: 'Visit was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:visit][:visit_date] = Date.strptime(params[:visit][:visit_date], "%m/%d/%Y") if params[:visit] and not params[:visit][:visit_date].blank?

    @visit = Visit.find_by_id(params[:id])

    if @visit and @visit.patient.editable_by?(current_user)
      if @visit.update_attributes(params[:visit])
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
      redirect_to visits_path
    else
      redirect_to root_path
    end
  end
end
