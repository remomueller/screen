class Evaluation < ActiveRecord::Base
  # attr_accessible :patient_id, :administration_type, :evaluation_type, :administration_date, :source, :embletta_unit_number, :expected_receipt_date, :receipt_date, :storage_date, :subject_notified, :reimbursement_form_date, :scored_date, :ahi, :eligibility, :exclusion, :status, :comments

  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible'], ['fully eligible', 'fully eligible']]
  STATUS = [['---', nil], ['pass', 'pass'], ['fail', 'fail']]
  TOGGLE_FIELDS = [:source, :embletta_unit_number, :expected_receipt_date, :receipt_date, :storage_date, :subject_notified, :reimbursement_form_date, :scored_date, :ahi, :eligibility, :exclusion, :status]

  # Callbacks
  after_save :save_event

  # Concerns
  include Patientable

  # Named Scopes
  scope :with_eligibility, lambda { |arg| where( "evaluations.eligibility IN (?)", arg ) }
  scope :administration_before, lambda { |arg| where( "evaluations.administration_date < ?", arg+1.day ) }
  scope :administration_after, lambda { |arg| where( "evaluations.administration_date >= ?", arg ) }
  scope :receipt_before, lambda { |arg| where( "evaluations.receipt_date < ?", arg+1.day ) }
  scope :receipt_after, lambda { |arg| where( "evaluations.receipt_date >= ?", arg ) }
  scope :scored_before, lambda { |arg| where( "evaluations.scored_date < ?", arg+1.day ) }
  scope :scored_after, lambda { |arg| where( "evaluations.scored_date >= ?", arg ) }

  # Model Validation
  validates_presence_of :patient_id, :administration_date, :administration_type, :evaluation_type, :user_id

  # Model Relationships
  belongs_to :patient, -> { where deleted: false }, touch: true
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
    self.patient.destroy_event(self.class.name, self.id, administration_time, 'Administered')
    self.patient.destroy_event(self.class.name, self.id, receipt_time, 'Received')
    self.patient.destroy_event(self.class.name, self.id, scored_time, 'Scored')
  end

  def save_event
    events = self.patient.events.where( class_name: self.class.name, class_id: self.id ).to_a

    events.delete(self.patient.find_or_create_event(self.class.name, self.id, administration_time, 'Administered')) unless self.administration_date.blank?
    events.delete(self.patient.find_or_create_event(self.class.name, self.id, receipt_time, 'Received')) unless self.receipt_date.blank?
    events.delete(self.patient.find_or_create_event(self.class.name, self.id, scored_time, 'Scored')) unless self.scored_date.blank?

    events.each{ |e| e.destroy }
  end

end
