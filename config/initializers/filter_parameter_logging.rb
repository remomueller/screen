# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :mrn, :sex, :age, :address1, :city, :state, :zip, :phone_home, :phone_day, :phone_alt]
