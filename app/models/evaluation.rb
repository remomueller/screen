class Evaluation < ActiveRecord::Base
  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible'], ['fully eligible', 'fully eligible']]
  STATUS = [['---', nil], ['pass', 'pass'], ['fail', 'fail']]

  # Callbacks
  after_save :save_event

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["evaluations.patient_id in (select patients.id from patients where LOWER(patients.mrn) LIKE (?) or LOWER(patients.subject_code) LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }

  # Model Validation
  validates_presence_of :patient_id
  validates_presence_of :administration_date
  validates_presence_of :administration_type, :evaluation_type

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }, touch: true

  # Class Methods

  def name
    self.patient ? self.patient.code : self.id
  end

  def exclusion_name
    (choice = Choice.find_by_id(self.exclusion)) ? choice.name : ''
  end

  def administration_type_name
    (choice = Choice.find_by_id(self.administration_type)) ? choice.name : ''
  end

  def evaluation_type_name
    (choice = Choice.find_by_id(self.evaluation_type)) ? choice.name : ''
  end

  def administration_time
    self.administration_date.blank? ? '' : Time.zone.parse(self.administration_date.to_s + " 00:00:00")
  end

  def receipt_time
    self.receipt_date.blank? ? '' : Time.zone.parse(self.receipt_date.to_s + " 00:00:00")
  end

  def scored_time
    self.scored_date.blank? ? '' : Time.zone.parse(self.scored_date.to_s + " 00:00:00")
  end


  def destroy
    update_attribute :deleted, true
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, administration_time, 'Administered')
    event.update_attribute :deleted, true if event
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, receipt_time, 'Received')
    event.update_attribute :deleted, true if event
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, scored_time, 'Scored')
    event.update_attribute :deleted, true if event
  end

  def save_event
    events = self.patient.events.find_all_by_class_name_and_class_id(self.class.name, self.id)
    unless self.administration_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, administration_time, 'Administered')
      events = events - [event]
    end
    unless self.receipt_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, receipt_time, 'Received')
      events = events - [event]
    end
    unless self.scored_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, scored_time, 'Scored')
      events = events - [event]
    end
    events.each{ |e| e.destroy }
  end

end