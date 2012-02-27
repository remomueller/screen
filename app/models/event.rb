class Event < ActiveRecord::Base

  # # Callbacks
  # after_destroy :destroy_dependency

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["events.patient_id in (select patients.id from patients where patients.mrn LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }

  # Model Validation
  # validates_presence_of     :first_name
  # validates_presence_of     :last_name

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }

  # Class Methods

  def destroy
    update_attribute :deleted, true
  end

  def image
    case class_name when 'Mailing'
      'mail'
    when 'Call'
      'phone_1'
    when 'Prescreen'
      '3x3_grid'
    else
      '3x3_grid'
    end
  end

  # def destroy_dependency
  #   object = self.class_name.constantize.find_by_id(self.class_id)
  #   object.destroy if object and not object.deleted?
  # end
end
