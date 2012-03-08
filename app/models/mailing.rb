class Mailing < ActiveRecord::Base

  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible']]

  # Callbacks
  after_save :save_event

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["mailings.patient_id in (select patients.id from patients where patients.mrn LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }

  # Model Validation
  validates_presence_of :patient_id
  validates_presence_of :doctor_id
  validates_presence_of :sent_date

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }, touch: true
  belongs_to :doctor, conditions: { deleted: false }, touch: true

  # Class Methods

  def name
    self.patient ? self.patient.code : self.id
  end

  def participation_name
    (choice = Choice.find_by_id(self.participation)) ? choice.name : ''
  end

  def exclusion_name
    (choice = Choice.find_by_id(self.exclusion)) ? choice.name : ''
  end

  def sent_time
    self.sent_date.blank? ? '' : Time.zone.parse(self.sent_date.to_s + " 00:00:00")
  end

  def response_time
    self.response_date.blank? ? '' : Time.zone.parse(self.response_date.to_s + " 00:00:00")
  end

  def destroy
    update_attribute :deleted, true
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, sent_time, 'Mailing Sent')
    event.update_attribute :deleted, true if event
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, response_time, 'Mailing Response Received')
    event.update_attribute :deleted, true if event
  end

  def save_event
    events = self.patient.events.find_all_by_class_name_and_class_id(self.class.name, self.id)
    unless self.sent_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, sent_time, 'Mailing Sent')
      events = events - [event]
    end
    unless self.response_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, response_time, 'Mailing Response Received')
      events = events - [event]
    end
    events.each{ |e| e.destroy }
  end
end
