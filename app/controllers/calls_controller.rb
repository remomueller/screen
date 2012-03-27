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

    @order = Call.column_names.collect{|column_name| "calls.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "calls.patient_id"
    call_scope = call_scope.order(@order)

    @calls = call_scope.page(params[:page]).per(20) # (current_user.calls_per_page)
  end

  def show
    @call = Call.find_by_id(params[:id])
    redirect_to root_path unless @call and @call.patient.editable_by?(current_user)
  end

  def task_tracker_templates
    current_user.update_attribute :task_tracker_screen_token, params[:screen_token] unless params[:screen_token].blank?
    if defined?(TASK_TRACKER_URL)
      begin
        result_hash = send_message("templates.json", { 'api_token' => 'screen_token', 'screen_token' => current_user.task_tracker_screen_token }, "get")
        @templates = result_hash[:result].blank? ? [] : ActiveSupport::JSON.decode(result_hash[:result])
      rescue => e
        Rails.logger.debug "Error connecting to #{TASK_TRACKER_URL}/templates.json: #{e}"
      end
    else
      render nothing: true
    end
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
    params[:call_date] = Date.strptime(params[:call_date], "%m/%d/%Y") rescue ""
    params[:call_time] = Time.zone.parse(params[:call_time]) rescue Time.zone.parse("12am")
    params[:call_time] = Time.zone.parse("12am") if params[:call_time].blank?
    params[:call][:call_time] = Time.zone.parse(params[:call_date].strftime('%F') + " " + params[:call_time].strftime('%T')) rescue ""

    @call = current_user.calls.new(params[:call])

    if @call.save

      if @call.tt_template_id
        if defined?(TASK_TRACKER_URL)
          begin
            additional_text = "Subject Code: #{@call.patient.subject_code}\n\nCreated by Screen\n"
            result_hash = send_message("groups.json", { 'api_token' => 'screen_token', 'screen_token' => current_user.task_tracker_screen_token, 'template_id' => @call.tt_template_id, 'initial_due_date' => @call.call_time.to_date, 'additional_text' => additional_text }, "post")
            @group = result_hash[:result].blank? ? [] : ActiveSupport::JSON.decode(result_hash[:result])
          rescue => e
            Rails.logger.debug "Error connecting to #{TASK_TRACKER_URL}/groups.json: #{e}"
          end
        end
      end

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
      redirect_to calls_path
    else
      redirect_to root_path
    end
  end

    private

  def send_message(service, form_data = {}, method = "get", limit = 1)
    error = ''
    data = ''
    response = ''
    return { result: data, error: 'HTTP redirect too deep' } if limit < 0

    t_msg_start = Time.now

    service_url = "#{TASK_TRACKER_URL}/#{service}"

    url = URI.parse(service_url)

    use_secure = (url.scheme == 'https')

    begin
      https = Net::HTTP.new(url.host, url.port)
      https.open_timeout = 1000 # in seconds
      https.read_timeout = 3000 # in seconds
      https.use_ssl = true if use_secure

      headers = { 'Content-Type' => 'text/html', 'WWW-Authenticate' => 'Basic realm="Application"', 'Authorization' => "Basic #{Base64.strict_encode64("#{TT_EMAIL}:#{TT_PASSWORD}")}" }

      url = URI.parse(service_url)
      if method == "get"
        req = Net::HTTP::Get.new(url.path, headers)
      elsif method == "post"
        req = Net::HTTP::Post.new(url.path, headers)
      else
        return { error: 'Invalid HTTP Method' }
      end
      req.set_form_data(form_data.stringify_keys, ';') unless form_data.blank?

      https.start do |http|
        response = http.request(req)
      end
      data = response.body

      case response.class.name
      when 'Net::HTTPOK'
      when 'Net::HTTPRedirection'
        return send_message(response['location'].gsub(@source.file_server_host + "/", ''), {}, "get", limit - 1)
        # TODO Test file redirect
        # return send_message(response['location'].gsub(@source.file_server_host + "/", ''), form_data, method, limit - 1)
      else
        error = "Error: #{response.class.name} #{data}"
      end
    rescue => e
      error = e.to_s
      Rails.logger.debug "error: #{error}"
    end

    { result: data, error: error }
  end

end
