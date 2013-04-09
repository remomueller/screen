class Mailing < ActiveRecord::Base
  # attr_accessible :patient_id, :doctor_id, :sent_date, :response_date, :berlin, :ess, :eligibility, :exclusion, :participation, :risk_factor_ids, :comments, :user_id

  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible']]

  # Callbacks
  after_save :save_event

  # Concerns
  include Patientable, Parseable

  # Named Scopes
  scope :with_eligibility, lambda { |arg| where( "mailings.eligibility IN (?)", arg ) }
  scope :sent_before, lambda { |arg| where( "mailings.sent_date < ?", arg+1.day ) }
  scope :sent_after, lambda { |arg| where( "mailings.sent_date >= ?", arg ) }
  scope :response_before, lambda { |arg| where( "mailings.response_date < ?", arg+1.day ) }
  scope :response_after, lambda { |arg| where( "mailings.response_date >= ?", arg ) }

  # Don't include mailing where the participant is inelgibile in some other way (calls...)
  scope :exclude_ineligible, -> { where( "mailings.patient_id not in ( select DISTINCT(calls.patient_id) from calls where calls.eligibility = 'ineligible') and mailings.patient_id not in ( select DISTINCT(evaluations.patient_id) from evaluations where evaluations.eligibility = 'ineligible') and mailings.patient_id not in ( select DISTINCT(prescreens.patient_id) from prescreens where prescreens.eligibility = 'ineligible')" ) }

  # Model Validation
  validates_presence_of :patient_id, :doctor_id, :sent_date, :user_id

  # Model Relationships
  belongs_to :patient, -> { where deleted: false }, touch: true
  belongs_to :doctor, -> { where deleted: false }, touch: true
  has_and_belongs_to_many :risk_factors, class_name: 'Choice'
  belongs_to :user

  # Class Methods

  def name
    "##{self.id}"
  end

  def participation_name
    (choice = Choice.find_by_id(self.participation)) ? choice.name : ''
  end

  def exclusion_name
    (choice = Choice.find_by_id(self.exclusion)) ? choice.name : ''
  end

  def sent_time
    self.sent_date.blank? ? '' : Time.parse(self.sent_date.to_s + " 00:00:00")
  end

  def response_time
    self.response_date.blank? ? '' : Time.parse(self.response_date.to_s + " 00:00:00")
  end

  def destroy
    update_column :deleted, true
    self.patient.destroy_event(self.class.name, self.id, sent_time, 'Mailing Sent')
    self.patient.destroy_event(self.class.name, self.id, response_time, 'Mailing Response Received')
  end

  def save_event
    events = self.patient.events.find_all_by_class_name_and_class_id(self.class.name, self.id)

    events.delete(self.patient.find_or_create_event(self.class.name, self.id, sent_time, 'Mailing Sent')) unless self.sent_date.blank?
    events.delete(self.patient.find_or_create_event(self.class.name, self.id, response_time, 'Mailing Response Received')) unless self.response_date.blank?

    events.each{ |e| e.destroy }
  end

  # Tab delimited
  # Ignores Header Row (since it can't parse the date)
  # Doctor  Date of Mailing MRN Last Name First Name  Address1  City  State Zip Code  Home Phone  Day Phone
  def self.process_bulk(params, current_user)
    mailings = Mailing.current.count
    ignored_mailings = 0
    doctors = Doctor.current.count
    doctor_name = ''
    use_mrns = (params[:import_type] != 'subject_code')
    # gsub(/\u00a0/, ' ') This replaces non-breaking whitespace
    params[:tab_dump].gsub(/\u00a0/, ' ').split(/\r|\n/).each_with_index do |row, row_index|
      row = row.strip
      unless row.blank?
        row_array = row.split(/\t/)
        doctor_name = row_array[0]
        doctor_type = (params[:doctor_type].blank? ? 'cardiologist' : params[:doctor_type])

        sent_date = parse_date(row_array[1])

        if not doctor_name.blank? and row_array.size > 1 and not sent_date.blank?
          identifier = row_array[2].to_s.strip

          if use_mrns
            identifier = "0"*([0,8 - identifier.size].max) + identifier.to_s unless identifier.blank?
          end


          last_name = row_array[3].to_s.strip
          first_name = row_array[4].to_s.strip
          address1 = row_array[5].to_s.strip
          city = row_array[6].to_s.strip
          state = row_array[7].to_s.strip
          zip = row_array[8].to_s.strip
          phone_home = row_array[9].to_s.strip
          phone_day = row_array[10].to_s.strip

          doctor = Doctor.find_or_create_by_name_and_doctor_type(doctor_name, doctor_type, { user_id: current_user.id })

          if (use_mrns and identifier.size == 8) or (not use_mrns and not identifier.blank?)
            patient = if use_mrns
              Patient.find_or_create_by_mrn(identifier, { user_id: current_user.id })
            else
              Patient.find_or_create_by_subject_code(identifier, { user_id: current_user.id })
            end

            patient_params = { first_name: first_name, last_name: last_name, address1: address1, city: city, state: state, zip: zip, phone_home: phone_home, phone_day: phone_day }
            patient_params.reject!{|key, val| val.blank?}
            patient.update_attributes(patient_params)

            mailing = patient.mailings.find_or_create_by_sent_date_and_doctor_id(sent_date, doctor.id, { user_id: current_user.id })
          else
            ignored_mailings += 1
          end
        end
      end
    end

    { mailing: Mailing.current.count - mailings, doctor: Doctor.current.count - doctors, 'ignored mailing' => ignored_mailings }
  end

end
