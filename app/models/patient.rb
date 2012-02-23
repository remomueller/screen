class Patient < ActiveRecord::Base
  # Named Scopes
  scope :current, conditions: { deleted: false }
end
