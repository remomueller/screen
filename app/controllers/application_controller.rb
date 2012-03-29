class ApplicationController < ActionController::Base
  protect_from_forgery

  layout "contour/layouts/application"

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
end
