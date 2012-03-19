class PrescreensController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener, only: [:bulk]
  before_filter :check_screener_or_subject_handler, except: [:bulk]

  def inline_update
    @prescreen = Prescreen.find_by_id(params[:id])
    if params[:item] == 'risk_factors'
      params[:prescreen] ||= {}
      params[:prescreen][:risk_factor_ids] ||= []
      @prescreen.update_attributes(params[:prescreen])
    else
      item = Prescreen::EDITABLES.include?(params[:item]) ? params[:item].to_sym : ''
      @prescreen.update_attribute(item, params[:update_value]) if @prescreen and not item.blank?
    end
  end

  def bulk
    count_hash = Prescreen.process_bulk(params, current_user)
    notices = []
    alerts = []
    count_hash.each do |key, count|
      if key.to_s == 'ignored prescreen'
        alerts << "#{count} prescreen#{'s' unless count == 1} ignored" if count > 0
      else
        notices << "#{count} #{key}#{'s' unless count == 1} added" if (count > 0 and key.to_s != 'prescreen') or key.to_s == 'prescreen'
      end
    end
    redirect_to prescreens_path, notice: notices.join(', '), alert: alerts.join(', ')
  end

  def index
    # current_user.update_attribute :prescreens_per_page, params[:prescreens_per_page].to_i if params[:prescreens_per_page].to_i >= 10 and params[:prescreens_per_page].to_i <= 200
    prescreen_scope = Prescreen.current # current_user.all_viewable_prescreens
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      prescreen_scope = prescreen_scope.with_mrn(term) unless term.blank?
    end

    prescreen_scope = prescreen_scope.subject_code_not_blank unless current_user.screener?

    @order = Prescreen.column_names.collect{|column_name| "prescreens.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "prescreens.doctor_id, prescreens.visit_at DESC"
    prescreen_scope = prescreen_scope.order(@order)

    @prescreens = prescreen_scope.page(params[:page]).per(40) # (current_user.prescreens_per_page)
  end

  def show
    @prescreen = Prescreen.find_by_id(params[:id])
    redirect_to root_path unless @prescreen and @prescreen.patient.editable_by?(current_user)
  end

  def new
    @prescreen = Prescreen.new(patient_id: params[:patient_id])
    redirect_to root_path unless @prescreen and @prescreen.patient.editable_by?(current_user)
  end

  def edit
    @prescreen = Prescreen.find_by_id(params[:id])
    redirect_to root_path unless @prescreen and @prescreen.patient.editable_by?(current_user)
  end

  def create
    params[:visit_date] = Date.strptime(params[:visit_date], "%m/%d/%Y") rescue ""
    params[:visit_time] = Time.zone.parse(params[:visit_time]) rescue Time.zone.parse("12am")
    params[:visit_time] = Time.zone.parse("12am") if params[:visit_time].blank?
    params[:prescreen][:visit_at] = Time.zone.parse(params[:visit_date].strftime('%F') + " " + params[:visit_time].strftime('%T')) rescue ""

    @prescreen = current_user.prescreens.new(params[:prescreen])

    if @prescreen.save
      redirect_to @prescreen.patient, notice: 'Prescreen was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:visit_date] = Date.strptime(params[:visit_date], "%m/%d/%Y") rescue ""
    params[:visit_time] = Time.zone.parse(params[:visit_time]) rescue Time.zone.parse("12am")
    params[:visit_time] = Time.zone.parse("12am") if params[:visit_time].blank?
    params[:prescreen][:visit_at] = Time.zone.parse(params[:visit_date].strftime('%F') + " " + params[:visit_time].strftime('%T')) rescue ""
    params[:prescreen][:risk_factor_ids] ||= []

    @prescreen = Prescreen.find_by_id(params[:id])

    if @prescreen and @prescreen.patient.editable_by?(current_user)
      if @prescreen.update_attributes(params[:prescreen])
        redirect_to @prescreen, notice: 'Prescreen was successfully updated.'
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @prescreen = Prescreen.find_by_id(params[:id])
    if @prescreen and @prescreen.patient.editable_by?(current_user)
      @prescreen.destroy
      redirect_to prescreens_path
    else
      redirect_to root_path
    end
  end
end
