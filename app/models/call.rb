class Call < ActiveRecord::Base

  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible']]

  # Callbacks
  after_save :save_event

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["calls.patient_id in (select patients.id from patients where patients.mrn LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }

  # Model Validation
  validates_presence_of :patient_id
  validates_presence_of :call_time

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }, touch: true

  # Class Methods

  def call_date
    self.call_time.strftime("%m/%d/%Y") rescue ""
  end

  def call_at_string
    self.call_time.blank? ? '' : call_time.localtime.strftime("%l:%M %p").strip
  end

  def name
    self.patient ? self.patient.code : self.id
  end

  def participation_name
    (choice = Choice.find_by_id(self.participation)) ? choice.name : ''
  end

  def exclusion_name
    (choice = Choice.find_by_id(self.exclusion)) ? choice.name : ''
  end

  def destroy
    update_attribute :deleted, true
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, self.call_time, 'Phone Call')
    event.update_attribute :deleted, true if event
  end

  def save_event
    events = self.patient.events.find_all_by_class_name_and_class_id(self.class.name, self.id)
    unless self.call_time.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, self.call_time, 'Phone Call')
      events = events - [event]
    end
    events.each{ |e| e.destroy }
  end

end
