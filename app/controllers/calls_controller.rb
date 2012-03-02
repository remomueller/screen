class CallsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin

  def index
    # current_user.update_attribute :calls_per_page, params[:calls_per_page].to_i if params[:calls_per_page].to_i >= 10 and params[:calls_per_page].to_i <= 200
    call_scope = Call.current # current_user.all_viewable_calls
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      call_scope = call_scope.with_mrn(term) unless term.blank?
    end

    @order = Call.column_names.collect{|column_name| "calls.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "calls.id"
    call_scope = call_scope.order(@order)

    @calls = call_scope.page(params[:page]).per(20) # (current_user.calls_per_page)
  end

  def show
    @call = Call.find(params[:id])
  end

  def new
    @call = Call.new(patient_id: params[:patient_id])
  end

  def edit
    @call = Call.find(params[:id])
  end

  def create
    params[:call_date] = Date.strptime(params[:call_date], "%m/%d/%Y") rescue ""
    params[:call_time] = Time.zone.parse(params[:call_time]) rescue Time.zone.parse("12am")
    params[:call_time] = Time.zone.parse("12am") if params[:call_time].blank?
    params[:call][:call_time] = Time.zone.parse(params[:call_date].strftime('%F') + " " + params[:call_time].strftime('%T')) rescue ""

    @call = Call.new(params[:call])

    if @call.save
      redirect_to @call.patient, notice: 'Call was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:call_date] = Date.strptime(params[:call_date], "%m/%d/%Y") rescue ""
    params[:call_time] = Time.zone.parse(params[:call_time]) rescue Time.zone.parse("12am")
    params[:call_time] = Time.zone.parse("12am") if params[:call_time].blank?
    params[:call][:call_time] = Time.zone.parse(params[:call_date].strftime('%F') + " " + params[:call_time].strftime('%T')) rescue ""

    @call = Call.find(params[:id])

    if @call.update_attributes(params[:call])
      redirect_to @call, notice: 'Call was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @call = Call.find(params[:id])
    @call.destroy

    redirect_to calls_path
  end
end
