class Patient < ActiveRecord::Base
  # attr_accessible :mrn, :subject_code, :name_code, :first_name, :last_name, :phone_home, :phone_day, :phone_alt, :sex, :age, :address1, :city, :state, :zip, :priority, :priority_message, :user_id, :email

  EDITABLES = ['phone_home', 'city', 'state']
  PRIORITY_MESSAGES = [["Latest Call is ...", "Latest Call is %"], ["Latest Call is ... and no Embletta Administered", "Latest Call is % and no Embletta Administered"], ["Baseline Visit and no 2-month Call after 68 days", "Baseline Visit and no 2-month Call after 68 days"]]

  # Concerns
  include Deletable

  # Named Scopes
  scope :with_mrn, lambda { |arg| where( "LOWER(patients.mrn) LIKE ? or
                                          LOWER(patients.subject_code) LIKE ? or
                                          LOWER(patients.first_name) LIKE ? or
                                          LOWER(patients.last_name) LIKE ? or
                                          LOWER(patients.phone_home) LIKE ? or
                                          LOWER(patients.phone_day) LIKE ? or
                                          LOWER(patients.phone_alt) LIKE ? or
                                          LOWER(patients.email) LIKE ?",
                                          arg.to_s.downcase + '%',
                                          arg.to_s.downcase.gsub(/^| |$/, '%'),
                                          arg.to_s.downcase.gsub(/^| |$/, '%'),
                                          arg.to_s.downcase.gsub(/^| |$/, '%'),
                                          arg.to_s.downcase.gsub(/^| |$/, '%'),
                                          arg.to_s.downcase.gsub(/^| |$/, '%'),
                                          arg.to_s.downcase.gsub(/^| |$/, '%'),
                                          arg.to_s.downcase.gsub(/^| |$/, '%') ) }
  scope :subject_code_not_blank, -> { where "patients.subject_code != ''" }
  scope :with_priority_message, lambda { |arg| where( "patients.priority_message LIKE ?", "%" + arg + "%" ) }

  # Model Validation
  validates_presence_of :mrn, if: :no_subject_code?
  validates_length_of :mrn, is: 8, if: :no_subject_code?
  validates_uniqueness_of :mrn, allow_blank: true, scope: :deleted
  validates_presence_of :subject_code, if: :no_mrn?
  validates_uniqueness_of :subject_code, allow_blank: true, scope: :deleted
  validates_presence_of :user_id

  # Model Relationships
  has_many :calls, -> { where deleted: false }
  has_many :evaluations, -> { where deleted: false }
  has_many :events, -> { where deleted: false }
  has_many :mailings, -> { where deleted: false }
  has_many :prescreens, -> { where deleted: false }
  has_many :visits, -> { where deleted: false }
  belongs_to :user

  # Class Methods

  # The following require access_phi to view
  # mrn, first_name, last_name, sex, age, phone_home, phone_day, phone_alt, address1, city, state, zip

  def destroy_event(class_name, class_id, event_time, event_name)
    event = find_event(class_name, class_id, event_time, event_name)
    event.destroy if event
  end

  def find_event(class_name, class_id, event_time, event_name)
    self.events.find_by_class_name_and_class_id_and_event_time_and_name(class_name, class_id, event_time, event_name)
  end

  def find_or_create_event(class_name, class_id, event_time, event_name)
    self.events.where(class_name: class_name, class_id: class_id, event_time: event_time, name: event_name).first_or_create
  end

  def scrubbed
    '---'
  end

  def phi_mrn(current_user)
    current_user.access_phi? ? self.mrn : self.scrubbed
  end

  def phi_mrn_organization(current_user)
    current_user.access_phi? ? self.mrn_organization : self.scrubbed
  end

  def phi_name(current_user)
    current_user.access_phi? ? self.name : self.scrubbed
  end

  def phi_first_name(current_user)
    current_user.access_phi? ? self.first_name : self.scrubbed
  end

  def phi_last_name(current_user)
    current_user.access_phi? ? self.last_name : self.scrubbed
  end

  def phi_sex(current_user)
    current_user.access_phi? ? self.sex : self.scrubbed
  end

  def phi_age(current_user)
    current_user.access_phi? ? self.age : self.scrubbed
  end

  def phi_phone_home(current_user)
    current_user.access_phi? ? self.phone_home : self.scrubbed
  end

  def phi_phone_day(current_user)
    current_user.access_phi? ? self.phone_day : self.scrubbed
  end

  def phi_phone_alt(current_user)
    current_user.access_phi? ? self.phone_alt : self.scrubbed
  end

  def phi_address(current_user)
    current_user.access_phi? ? self.address : self.scrubbed
  end

  def phi_address1(current_user)
    current_user.access_phi? ? self.address1 : self.scrubbed
  end

  def phi_city(current_user)
    current_user.access_phi? ? self.city : self.scrubbed
  end

  def phi_state(current_user)
    current_user.access_phi? ? self.state : self.scrubbed
  end

  def phi_zip(current_user)
    current_user.access_phi? ? self.zip : self.scrubbed
  end

  def phi_email(current_user)
    current_user.access_phi? ? self.email : self.scrubbed
  end

  def editable_by?(current_user)
    current_user.screener? or (not self.subject_code.blank? and current_user.subject_handler?)
  end

  # Study Code if available, if not, MRN
  def phi_code(current_user)
    self.subject_code.blank? ? (current_user.access_phi? ? self.mrn : self.scrubbed) : self.subject_code
  end

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def address
    [self.address1, self.city, self.state, self.zip].select{|i| not i.blank?}.join(', ')
  end

  def no_subject_code?
    self.subject_code.blank?
  end

  def no_mrn?
    self.mrn.blank?
  end

  def berlin_from_calls_and_mailings
    (self.calls.pluck(:berlin) + self.mailings.pluck(:berlin)).compact.uniq.sort
  end

  def ess_from_calls_and_mailings
    (self.calls.pluck(:ess) + self.mailings.pluck(:ess)).compact.uniq.sort
  end

  def self.merge_dup_patients!
    duplicate_patient_mrns = Patient.current.pluck(:mrn).select{|mrn| not mrn.blank?}.group_by{|mrn| mrn}.select{|key,val| val.length > 1}.keys
    duplicate_patient_mrns.each do |mrn|
      same_patients = Patient.current.where(mrn: mrn).order(:id)
      first_patient = same_patients.first
      same_patients[1..-1].each do |p|
        p.calls.update_all( patient_id: first_patient.id )
        p.evaluations.update_all( patient_id: first_patient.id )
        p.events.update_all( patient_id: first_patient.id )
        p.mailings.update_all( patient_id: first_patient.id )
        p.prescreens.update_all( patient_id: first_patient.id )
        p.visits.update_all( patient_id: first_patient.id )
        p.destroy
      end
    end
    Patient.current.pluck(:mrn).select{|mrn| not mrn.blank?}.group_by{|mrn| mrn}.select{|key,val| val.length > 1}.keys.size
  end

end
