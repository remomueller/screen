class Call < ActiveRecord::Base

  # Callbacks
  after_save :save_event

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["calls.patient_id in (select patients.id from patients where patients.mrn LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }

  # Model Validation

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }

  # Class Methods

  def name
    if self.patient
      self.patient.mrn
    else
      self.id
    end.to_s
  end

  def destroy
    update_attribute :deleted, true
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, self.call_time, 'Phone Call')
    event.update_attribute :deleted, true if event
  end

  def save_event
    event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, self.call_time, 'Phone Call') unless self.call_time.blank?
  end

end
