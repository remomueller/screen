class ApplicationController < ActionController::Base
  protect_from_forgery

  layout "contour/layouts/application"

  protected

  def check_system_admin
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.system_admin?
  end

  def check_screener
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.screener?
  end

  def check_screener_or_subject_handler
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.screener? or current_user.subject_handler?
  end

  def pretty_phone(phone)
    digits = phone.to_s.gsub(/[^\d]/, '')
    if digits.size == 10
      digits[0..2] + "-" + digits[3..5] + "-" + digits[6..-1]
    elsif digits.size == 11
      digits[0] + "-" + digits[1..3] + "-" + digits[4..6] + "-" + digits[7..-1]
    else
      phone
    end
  end

  # The primary version. If updated, also update the function in app/models/mailing.rb and app/models/prescreen.rb
  def parse_date(date_string, default_date = '')
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue default_date
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(' ')
    direction = (params_direction == 'desc' ? 'DESC' : nil)
    column_name = (model.column_names.collect{|c| model.table_name + "." + c}.select{|c| c == params_column}.first)
    order = column_name.blank? ? default_order : [column_name, direction].compact.join(' ')
    order
  end

  private

  def send_message(service, form_data = {}, method = "get", limit = 1, service_url = '')
    return { result: '', error: 'No Task Tracker URL provided' } if TASK_TRACKER_URL.blank? or TT_EMAIL.blank? or TT_PASSWORD.blank?
    error = ''
    data = ''
    response = ''
    return { result: data, error: 'HTTP redirect too deep' } if limit < 0

    t_msg_start = Time.now

    service_url = "#{TASK_TRACKER_URL}/#{service}" if service_url.blank?

    begin
      url = URI.parse(service_url)
      use_secure = (url.scheme == 'https')

      https = Net::HTTP.new(url.host, url.port)
      https.open_timeout = 1000 # in seconds
      https.read_timeout = 3000 # in seconds
      https.use_ssl = true if use_secure
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE if use_secure

      headers = { 'Content-Type' => 'text/html', 'WWW-Authenticate' => 'Basic realm="Application"', 'Authorization' => "Basic #{Base64.strict_encode64("#{TT_EMAIL}:#{TT_PASSWORD}")}" }

      url = URI.parse(service_url)
      req = if method == "post"
        Net::HTTP::Post.new(url.path, headers)
      else # elsif method == "get"
        Net::HTTP::Get.new(url.path, headers)
      end
      req.set_form_data(form_data.stringify_keys, ';') unless form_data.blank?

      https.start do |http|
        response = http.request(req)
      end
      data = response.body

      if response.kind_of?(Net::HTTPSuccess)
        # Do nothing, success!
      elsif response.kind_of?(Net::HTTPRedirection)
        return send_message(service, form_data, method, limit - 1, response['location'])
      else
        error = "Error: #{response.class.name} #{data}"
        data = ''
      end
    rescue => e
      error = e.to_s
      Rails.logger.debug "Error: #{error} #{data}"
      data = ''
    end

    { result: data, error: error }
  end
end
