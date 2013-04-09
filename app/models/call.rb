class Call < ActiveRecord::Base
  # attr_accessible :patient_id, :call_type, :direction, :response, :call_time, :berlin, :ess, :eligibility, :exclusion, :participation, :comments, :tt_template_id, :tt_group_id

  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible']]
  CALL_DIRECTION = [['---', nil], ['incoming', 'incoming'], ['outgoing','outgoing']]
  TOGGLE_FIELDS = [:response, :berlin, :ess, :eligibility, :exclusion, :participation]

  # Callbacks
  after_save :save_event

  # Concerns
  include Patientable

  # Named Scopes
  scope :with_eligibility, lambda { |arg| where( "calls.eligibility IN (?)", arg ) }
  scope :with_user, lambda { |arg| where( "calls.user_id in (?)", arg ) }
  scope :with_response, lambda { |arg| where( "calls.response in (?)", arg ) }
  scope :call_before, lambda { |arg| where( "calls.call_time < ?", (arg+1.day).at_midnight ) }
  scope :call_after, lambda { |arg| where( "calls.call_time >= ?", arg.at_midnight ) }

  # Model Validation
  validates_presence_of :patient_id, :call_time, :call_type, :direction, :user_id

  # Model Relationships
  belongs_to :patient, -> { where deleted: false }, touch: true
  belongs_to :user

  # Class Methods

  def call_type_name
    (choice = Choice.find_by_id(self.call_type)) ? choice.name : ''
  end

  def response_name
    (choice = Choice.find_by_id(self.response)) ? choice.name : ''
  end

  def call_date
    self.call_time.strftime("%m/%d/%Y") rescue ""
  end

  def call_at_string
    self.call_time.blank? ? '' : call_time.localtime.strftime("%l:%M %p").strip
  end

  def name
    "##{self.id}"
  end

  def participation_name
    (choice = Choice.find_by_id(self.participation)) ? choice.name : ''
  end

  def exclusion_name
    (choice = Choice.find_by_id(self.exclusion)) ? choice.name : ''
  end

  def destroy
    update_column :deleted, true
    self.patient.destroy_event(self.class.name, self.id, self.call_time, 'Phone Call')
  end

  def save_event
    events = self.patient.events.where( class_name: self.class.name, class_id: self.id ).to_a
    events.delete(self.patient.find_or_create_event(self.class.name, self.id, self.call_time, 'Phone Call')) unless self.call_time.blank?
    events.each{ |e| e.destroy }
  end

end
