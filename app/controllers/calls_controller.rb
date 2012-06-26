class CallsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_screener_or_subject_handler

  def index
    # current_user.update_attribute :calls_per_page, params[:calls_per_page].to_i if params[:calls_per_page].to_i >= 10 and params[:calls_per_page].to_i <= 200
    call_scope = Call.current # current_user.all_viewable_calls
    params[:mrn].to_s.gsub(/[^\da-zA-Z]/, ' ').split(' ').each do |term|
      call_scope = call_scope.with_mrn(term) unless term.blank?
    end

    call_scope = call_scope.subject_code_not_blank unless current_user.screener?
    call_scope = call_scope.with_eligibility(params[:eligibility]) unless params[:eligibility].blank?

    @call_after = begin Date.strptime(params[:call_after], "%m/%d/%Y") rescue nil end
    @call_before = begin Date.strptime(params[:call_before], "%m/%d/%Y") rescue nil end

    call_scope = call_scope.call_before(@call_before) unless @call_before.blank?
    call_scope = call_scope.call_after(@call_after) unless @call_after.blank?

    call_scope = call_scope.with_user(params[:user_id]) unless params[:user_id].blank?
    call_scope = call_scope.with_response(params[:response_id]) unless params[:response_id].blank?

    @order = Call.column_names.collect{|column_name| "calls.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "calls.patient_id"
    call_scope = call_scope.order(@order)

    if params[:format] == 'csv'
      generate_csv(call_scope)
      return
    end

    @call_count = call_scope.count
    @calls = call_scope.page(params[:page]).per(20) # (current_user.calls_per_page)
  end

  def show
    @call = Call.find_by_id(params[:id])
    redirect_to root_path unless @call and @call.patient.editable_by?(current_user)
  end

  def show_group
    @call = Call.find_by_id(params[:id])
    if @call
      current_user.update_attribute :task_tracker_screen_token, params[:screen_token] unless params[:screen_token].blank?
      result_hash = send_message("groups/#{@call.tt_group_id}.json", { 'api_token' => 'screen_token', 'screen_token' => current_user.task_tracker_screen_token }, "get")
      @group = result_hash[:result].blank? ? {} : ActiveSupport::JSON.decode(result_hash[:result])
    else
      render nothing: true
    end
  end

  def task_tracker_templates
    current_user.update_attribute :task_tracker_screen_token, params[:screen_token] unless params[:screen_token].blank?
    result_hash = send_message("templates.json", { 'api_token' => 'screen_token', 'screen_token' => current_user.task_tracker_screen_token, 'editable_only' => '1' }, "get")
    @templates = result_hash[:result].blank? ? [] : ActiveSupport::JSON.decode(result_hash[:result])
  end

  def new
    @call = Call.new(patient_id: params[:patient_id])
    @templates = []
    redirect_to root_path unless @call and @call.patient.editable_by?(current_user)
  end

  def edit
    @call = Call.find_by_id(params[:id])
    redirect_to root_path unless @call and @call.patient.editable_by?(current_user)
  end

  def create
    params[:call_date] = parse_date(params[:call_date])
    # params[:call_date] = Date.strptime(params[:call_date], "%m/%d/%Y") rescue ""
    params[:call_time] = Time.parse(params[:call_time]) rescue Time.parse("12am")
    params[:call_time] = Time.parse("12am") if params[:call_time].blank?
    params[:call][:call_time] = Time.parse(params[:call_date].strftime('%F') + " " + params[:call_time].strftime('%T')) rescue ""

    @call = current_user.calls.new(params[:call])

    if @call.save

      if @call.tt_template_id
        additional_text = "Subject Code: #{@call.patient.subject_code}\n\nCreated by Screen\n\n#{@call.comments}"
        result_hash = send_message("groups.json", { 'api_token' => 'screen_token', 'screen_token' => current_user.task_tracker_screen_token, 'template_id' => @call.tt_template_id, 'initial_due_date' => params[:initial_due_date], 'additional_text' => additional_text }, "post")
        @group = result_hash[:result].blank? ? {} : ActiveSupport::JSON.decode(result_hash[:result])
        @call.update_attribute :tt_group_id, @group['id'] unless @group['id'].blank?
      end

      redirect_to @call.patient, notice: 'Call was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:call_date] = parse_date(params[:call_date])
    # params[:call_date] = Date.strptime(params[:call_date], "%m/%d/%Y") rescue ""
    params[:call_time] = Time.parse(params[:call_time]) rescue Time.parse("12am")
    params[:call_time] = Time.parse("12am") if params[:call_time].blank?
    params[:call][:call_time] = Time.parse(params[:call_date].strftime('%F') + " " + params[:call_time].strftime('%T')) rescue ""

    @call = Call.find_by_id(params[:id])

    if @call and @call.patient.editable_by?(current_user)
      if @call.update_attributes(params[:call])
        redirect_to @call, notice: 'Call was successfully updated.'
      else
        render action: "edit"
      end
    else
      redirect_to root_path
    end
  end

  def destroy
    @call = Call.find_by_id(params[:id])
    if @call and @call.patient.editable_by?(current_user)
      @call.destroy
      redirect_to calls_path, notice: 'Call was successfully deleted.'
    else
      redirect_to root_path
    end
  end

  private

  def generate_csv(call_scope)
    if params[:format] == 'csv'
      @csv_string = CSV.generate do |csv|
        csv << ["Patient ID", "Subject Code", "Call Time", "Call Type", "Response", "Response Code", "Participation", "Participation Code", "Exclusion", "Exclusion Code", "Berlin", "ESS", "Eligibility", "Direction", "Comments"]
        call_scope.each do |call|
          csv << [
            call.patient.id,
            call.patient.subject_code,
            call.call_time.strftime("%Y-%m-%d %T %z"),
            call.call_type_name,
            call.response_name,
            call.response,
            call.participation_name,
            call.participation,
            call.exclusion_name,
            call.exclusion,
            call.berlin,
            call.ess,
            call.eligibility,
            call.direction,
            call.comments
          ]
        end
      end
      send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                            disposition: "attachment; filename=\"Calls #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
    end
  end

end
