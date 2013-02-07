module Parseable
  extend ActiveSupport::Concern

  module ClassMethods
    # The primary version of this is in app/controllers/application_controller.rb
    def parse_date(date_string, default_date = '')
      date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue default_date
    end
  end
end
