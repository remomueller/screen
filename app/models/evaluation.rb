class Evaluation < ActiveRecord::Base
  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible']]
  STATUS = [['---', nil], ['pass', 'pass'], ['fail', 'fail']]

  # Callbacks
  after_save :save_event

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["evaluations.patient_id in (select patients.id from patients where patients.mrn LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }

  # Model Validation
  validates_presence_of :patient_id
  validates_presence_of :assessment_date
  validates_presence_of :assessment_type, :evaluation_type

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }, touch: true

  # Class Methods

  def name
    self.patient ? self.patient.mrn : self.id
  end

  def exclusion_name
    (choice = Choice.find_by_id(self.exclusion)) ? choice.name : ''
  end

  def assessment_type_name
    (choice = Choice.find_by_id(self.assessment_type)) ? choice.name : ''
  end

  def evaluation_type_name
    (choice = Choice.find_by_id(self.evaluation_type)) ? choice.name : ''
  end

  def assessment_time
    self.assessment_date.blank? ? '' : Time.zone.parse(self.assessment_date.to_s + " 00:00:00")
  end

  def receipt_time
    self.receipt_date.blank? ? '' : Time.zone.parse(self.receipt_date.to_s + " 00:00:00")
  end

  def scored_time
    self.scored_date.blank? ? '' : Time.zone.parse(self.scored_date.to_s + " 00:00:00")
  end


  def destroy
    update_attribute :deleted, true
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, assessment_time, 'Evaluation Assessed')
    event.update_attribute :deleted, true if event
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, receipt_time, 'Evaluation Received')
    event.update_attribute :deleted, true if event
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, scored_time, 'Evaluation Scored')
    event.update_attribute :deleted, true if event
  end

  def save_event
    events = self.patient.events.find_all_by_class_name_and_class_id(self.class.name, self.id)
    unless self.assessment_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, assessment_time, 'Evaluation Assessed')
      events = events - [event]
    end
    unless self.receipt_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, receipt_time, 'Evaluation Received')
      events = events - [event]
    end
    unless self.scored_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, scored_time, 'Evaluation Scored')
      events = events - [event]
    end
    events.each{ |e| e.destroy }
  end

end
