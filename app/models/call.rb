class Call < ActiveRecord::Base

  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible']]
  CALL_DIRECTION = [['---', nil], ['incoming', 'incoming'], ['outgoing','outgoing']]
  TOGGLE_FIELDS = [:response, :berlin, :ess, :eligibility, :exclusion, :participation]

  # Callbacks
  after_save :save_event

  # Named Scopes
  scope :current, conditions: ["calls.deleted = ? and calls.patient_id IN (select patients.id from patients where patients.deleted = ?)", false, false]
  scope :with_mrn, lambda { |*args| { conditions: ["calls.patient_id in (select patients.id from patients where LOWER(patients.mrn) LIKE (?) or LOWER(patients.subject_code) LIKE (?) or
                                                                                                                LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?) or
                                                                                                                LOWER(patients.phone_home) LIKE (?) or LOWER(patients.phone_day) LIKE (?) or LOWER(patients.phone_alt) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }
  scope :with_eligibility, lambda { |*args| { conditions: ["calls.eligibility IN (?)", args.first] } }
  scope :with_user, lambda { |*args| { conditions: ["calls.user_id in (?)", args.first] } }
  scope :with_response, lambda { |*args| { conditions: ["calls.response in (?)", args.first] } }
  scope :subject_code_not_blank, conditions: ["calls.patient_id in (select patients.id from patients where patients.subject_code != '')"]
  scope :call_before, lambda { |*args| { conditions: ["calls.call_time < ?", (args.first+1.day).at_midnight]} }
  scope :call_after, lambda { |*args| { conditions: ["calls.call_time >= ?", args.first.at_midnight]} }

  # Model Validation
  validates_presence_of :patient_id
  validates_presence_of :call_time
  validates_presence_of :call_type
  validates_presence_of :direction

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }, touch: true
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
