class Event < ActiveRecord::Base
  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["events.patient_id in (select patients.id from patients where patients.mrn LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }

  # Model Validation
  # validates_presence_of     :first_name
  # validates_presence_of     :last_name

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }

  # Class Methods

  def image
    case class_name when 'Mailing'
      'mail'
    else
      '3x3_grid'
    end
  end
end
