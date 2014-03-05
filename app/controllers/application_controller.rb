class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!, only: [ :dashboard ]

  layout "contour/layouts/application"

  def dashboard
    flash.delete(:notice)
  end

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

  def empty_response_or_root_path(path = root_path)
    respond_to do |format|
      format.html { redirect_to path }
      format.js { render nothing: true }
      format.json { head :no_content }
    end
  end
end
