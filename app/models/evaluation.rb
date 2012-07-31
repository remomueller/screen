class Evaluation < ActiveRecord::Base
  attr_accessible :patient_id, :administration_type, :evaluation_type, :administration_date, :source, :embletta_unit_number, :expected_receipt_date, :receipt_date, :storage_date, :subject_notified, :reimbursement_form_date, :scored_date, :ahi, :eligibility, :exclusion, :status, :comments

  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible'], ['fully eligible', 'fully eligible']]
  STATUS = [['---', nil], ['pass', 'pass'], ['fail', 'fail']]
  TOGGLE_FIELDS = [:source, :embletta_unit_number, :expected_receipt_date, :receipt_date, :storage_date, :subject_notified, :reimbursement_form_date, :scored_date, :ahi, :eligibility, :exclusion, :status]

  # Callbacks
  after_save :save_event

  # Named Scopes
  scope :current, conditions: ["evaluations.deleted = ? and evaluations.patient_id IN (select patients.id from patients where patients.deleted = ?)", false, false]
  scope :with_mrn, lambda { |*args| { conditions: ["evaluations.patient_id in (select patients.id from patients where LOWER(patients.mrn) LIKE (?) or LOWER(patients.subject_code) LIKE (?) or
                                                                                                                      LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?) or
                                                                                                                      LOWER(patients.phone_home) LIKE (?) or LOWER(patients.phone_day) LIKE (?) or LOWER(patients.phone_alt) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }
  scope :with_subject_code, lambda { |*args| { conditions: ["evaluations.patient_id in (select patients.id from patients where LOWER(patients.subject_code) IN (?))", args.first] } }
  scope :with_eligibility, lambda { |*args| { conditions: ["evaluations.eligibility IN (?)", args.first] } }
  scope :subject_code_not_blank, conditions: ["evaluations.patient_id in (select patients.id from patients where patients.subject_code != '')"]
  scope :administration_before, lambda { |*args| { conditions: ["evaluations.administration_date < ?", (args.first+1.day)]} }
  scope :administration_after, lambda { |*args| { conditions: ["evaluations.administration_date >= ?", args.first]} }
  scope :receipt_before, lambda { |*args| { conditions: ["evaluations.receipt_date < ?", (args.first+1.day)]} }
  scope :receipt_after, lambda { |*args| { conditions: ["evaluations.receipt_date >= ?", args.first]} }
  scope :scored_before, lambda { |*args| { conditions: ["evaluations.scored_date < ?", (args.first+1.day)]} }
  scope :scored_after, lambda { |*args| { conditions: ["evaluations.scored_date >= ?", args.first]} }


  # Model Validation
  validates_presence_of :patient_id, :administration_date, :administration_type, :evaluation_type, :user_id

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }, touch: true
  belongs_to :user

  # Class Methods

  def name
    "##{self.id}"
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
    self.administration_date.blank? ? '' : Time.parse(self.administration_date.to_s + " 00:00:00")
  end

  def receipt_time
    self.receipt_date.blank? ? '' : Time.parse(self.receipt_date.to_s + " 00:00:00")
  end

  def scored_time
    self.scored_date.blank? ? '' : Time.parse(self.scored_date.to_s + " 00:00:00")
  end


  def destroy
    update_column :deleted, true
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, administration_time, 'Administered')
    event.update_column :deleted, true if event
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, receipt_time, 'Received')
    event.update_column :deleted, true if event
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, scored_time, 'Scored')
    event.update_column :deleted, true if event
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
