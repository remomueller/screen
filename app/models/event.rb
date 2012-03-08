class Event < ActiveRecord::Base

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["events.patient_id in (select patients.id from patients where LOWER(patients.mrn) LIKE (?) or LOWER(patients.subject_code) LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }
  scope :with_patient, lambda { |*args| { conditions: ["events.patient_id LIKE ?", args.first] } }

  # Model Validation
  validates_presence_of :patient_id

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }, touch: true

  # Class Methods

  def destroy
    update_attribute :deleted, true
    # Does not make sense to delete the object if only one of its events is deleted.
    # object = self.class_name.constantize.find_by_id(self.class_id)
    # object.destroy if object and not object.deleted?
  end

  def image
    case class_name when 'Mailing'
      'mail'
    when 'Call'
      'phone_1'
    when 'Evaluation'
      'cert'
    else # 'Prescreen'
      '3x3_grid'
    end
  end

end
