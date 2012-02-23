class Event < ActiveRecord::Base
  # Named Scopes
  scope :current, conditions: { deleted: false }
end
