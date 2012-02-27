class Mailing < ActiveRecord::Base
  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["mailings.patient_id in (select patients.id from patients where patients.mrn LIKE (?))", args.first.to_s + '%'] } }

  # Model Validation
mailings
  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }

  # Class Methods

end
