class Visit < ActiveRecord::Base
  # attr_accessible :patient_id, :visit_type, :visit_date, :outcome, :comments

  # Callbacks
  after_save :save_event

  # Concerns
  include Patientable

  # Named Scopes
  scope :visit_before, lambda { |arg| where( "visits.visit_date < ?", arg+1.day ) }
  scope :visit_after, lambda { |arg| where( "visits.visit_date >= ?", arg ) }

  # Model Validation
  validates_presence_of :patient_id, :visit_type, :visit_date, :outcome, :user_id

  # Model Relationships
  belongs_to :patient, -> { where deleted: false }, touch: true
  belongs_to :user

  # Class Methods

  def eligibility
    ""
  end

  def exclusion_name
    ""
  end

  def name
    "##{self.id}"
  end

  def outcome_name
    (choice = Choice.find_by_id(self.outcome)) ? choice.name : ''
  end

  def visit_type_name
    (choice = Choice.find_by_id(self.visit_type)) ? choice.name : ''
  end

  def visit_time
    self.visit_date.blank? ? '' : Time.parse(self.visit_date.to_s + " 00:00:00")
  end

  def destroy
    update_column :deleted, true
    self.patient.destroy_event(self.class.name, self.id, visit_time, 'Visit')
  end

  def save_event
    events = self.patient.events.find_all_by_class_name_and_class_id(self.class.name, self.id)
    events.delete(self.patient.find_or_create_event(self.class.name, self.id, visit_time, 'Visit')) unless self.visit_date.blank?
    events.each{ |e| e.destroy }
  end

end
