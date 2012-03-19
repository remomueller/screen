class Visit < ActiveRecord::Base

  # Callbacks
  after_save :save_event

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["visits.patient_id in (select patients.id from patients where LOWER(patients.mrn) LIKE (?) or LOWER(patients.subject_code) LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }
  scope :subject_code_not_blank, conditions: ["visits.patient_id in (select patients.id from patients where patients.subject_code != '')"]

  # Model Validation
  validates_presence_of :patient_id
  validates_presence_of :visit_type
  validates_presence_of :visit_date
  validates_presence_of :outcome

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }, touch: true
  belongs_to :user

  # Class Methods

  def eligibility
    ""
  end

  def exclusion_name
    ""
  end

  def name
    self.patient ? self.patient.code : self.id
  end

  def outcome_name
    (choice = Choice.find_by_id(self.outcome)) ? choice.name : ''
  end

  def visit_type_name
    (choice = Choice.find_by_id(self.visit_type)) ? choice.name : ''
  end

  def visit_time
    self.visit_date.blank? ? '' : Time.zone.parse(self.visit_date.to_s + " 00:00:00")
  end

  def destroy
    update_attribute :deleted, true
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, visit_time, 'Visit')
    event.update_attribute :deleted, true if event
  end

  def save_event
    events = self.patient.events.find_all_by_class_name_and_class_id(self.class.name, self.id)
    unless self.visit_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, visit_time, 'Visit')
      events = events - [event]
    end
    events.each{ |e| e.destroy }
  end

end
