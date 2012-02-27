class Mailing < ActiveRecord::Base
  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["mailings.patient_id in (select patients.id from patients where patients.mrn LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }

  # Model Validation

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }

  # Class Methods
  def destroy
    update_attribute :deleted, true
  end

end
