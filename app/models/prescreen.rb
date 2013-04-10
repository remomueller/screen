class Prescreen < ActiveRecord::Base
  # attr_accessible :patient_id, :clinic_id, :doctor_id, :visit_at, :visit_duration, :visit_units, :eligibility, :exclusion, :risk_factor_ids, :comments, :user_id

  VALID_AGE = defined?(RULE_AGE) ? RULE_AGE : ()
  EDITABLES = ['eligibility', 'exclusion']
  RISK_FACTORS = defined?(RULE_RISK_FACTORS) ? RULE_RISK_FACTORS : []

  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible']]

  # Callbacks
  after_save :save_event

  # Concerns
  include Patientable, Parseable

  # Named Scopes
  scope :with_eligibility, lambda { |arg| where( "prescreens.eligibility IN (?)", arg ) }
  scope :visit_before, lambda { |arg| where( "prescreens.visit_at < ?", (arg+1.day).at_midnight ) }
  scope :visit_after, lambda { |arg| where( "prescreens.visit_at >= ?", arg.at_midnight ) }
  scope :with_no_calls, -> { where( "prescreens.patient_id not in (select DISTINCT(calls.patient_id) from calls)" ) }

  # Model Validation
  validates_presence_of :clinic_id, :doctor_id, :patient_id, :user_id
  validates_presence_of :visit_at, message: 'date and time can\'t be blank'

  # Model Relationships
  belongs_to :clinic, -> { where deleted: false }
  belongs_to :doctor, -> { where deleted: false }
  belongs_to :patient, -> { where deleted: false }, touch: true
  has_and_belongs_to_many :risk_factors, class_name: 'Choice'
  belongs_to :user

  # Class Methods

  def name
    "##{self.id}"
  end

  def exclusion_name
    (choice = Choice.find_by_id(self.exclusion)) ? choice.name : ''
  end

  def visit_date
    self.visit_at.strftime("%m/%d/%Y") rescue ""
  end

  def visit_at_string
    visit_at.blank? ? '' : visit_at.localtime.strftime("%l:%M %p").strip
  end

  def visit_at_string_short
    self.visit_at_string.gsub(':00', '').gsub(' AM', 'a').gsub(' PM', 'p')
  end

  def visit_at_end_string
    (visit_at.blank? or self.visit_duration <= 0) ? '' : (visit_at + self.visit_duration.send(self.visit_units)).localtime.strftime("%l:%M %p").strip
  end

  def visit_at_end_string_short
    self.visit_at_end_string.gsub(':00', '').gsub(' AM', 'a').gsub(' PM', 'p')
  end

  def visit_at_range_short
    self.visit_at_string_short + (self.visit_at_end_string_short.blank? ? '' : '-' + self.visit_at_end_string_short)
  end

  def destroy
    update_column :deleted, true
    self.patient.destroy_event(self.class.name, self.id, self.visit_at, 'Prescreen')
  end

  # Tab delimited
  # Ignore Potential Header Row...
  # Time  Status  Clinic  Patient Name  Sex/Age MRN Visit Type  Reason for Visit  PG
  # Includes "Appointment Date"
  # Includes Doctor Type
  def self.process_bulk(params, current_user)
    prescreens = Prescreen.current.count
    ignored_prescreens = 0
    doctors = Doctor.current.count
    clinics = Clinic.current.count
    doctor_name = ''
    appointment_date = parse_date(params[:visit_date], Date.today)
    # gsub(/\u00a0/, ' ') This replaces non-breaking whitespace
    params[:tab_dump].gsub(/\u00a0/, ' ').split(/\r|\n/).each_with_index do |row, row_index|
      row = row.strip
      unless row.blank?
        row_array = row.split(/\t/)
        doctor_name = row_array.first if row_array.size == 1
        doctor_type = (params[:doctor_type].blank? ? 'cardiologist' : params[:doctor_type])

        if not doctor_name.blank? and row_array.size > 1
          time = row_array[0]
          time_start = Time.parse(appointment_date.strftime('%Y-%m-%d') + ' ' + time.split(' - ').first)
          time_end = Time.parse(appointment_date.strftime('%Y-%m-%d') + ' ' + time.split(' - ').last)
          minutes = ((time_end - time_start) / 1.minute).to_i
          clinic_name = row_array[2]
          name = row_array[3]
          last_name = name.split(',').first.strip

          first_name = (name.split(',')[1..-1] || []).join(',').strip
          sex_age = row_array[4]
          sex = sex_age.split(' ').first
          age = (sex_age.split(' ')[1..-1] || []).join(' ').to_i
          mrn = row_array[5].to_s.strip
          mrn = "0"*([0,8 - mrn.size].max) + mrn.to_s unless mrn.blank?

          reason_for_visit = row_array[6]
          comment = row_array[7]

          clinic = Clinic.where( name: clinic_name ).first_or_create( user_id: current_user.id )
          doctor = Doctor.where( name: doctor_name, doctor_type: doctor_type ).first_or_create( user_id: current_user.id )

          if (Prescreen::VALID_AGE.blank? or Prescreen::VALID_AGE.include?(age)) and not doctor.blacklisted? and not clinic.blacklisted? and mrn.size == 8
            patient = Patient.where( mrn: mrn ).first_or_create( user_id: current_user.id )
            patient.update_attributes( first_name: first_name, last_name: last_name, sex: sex, age: age )
            prescreen = patient.prescreens.where( visit_at: time_start, clinic_id: clinic.id, doctor_id: doctor.id ).first_or_create( user_id: current_user.id )
            prescreen.update_attributes( visit_duration: minutes, visit_units: 'minutes' )
          else
            ignored_prescreens += 1
          end
        end
      end
    end

    { prescreen: Prescreen.current.count - prescreens, doctor: Doctor.current.count - doctors, clinic: Clinic.current.count - clinics, 'ignored prescreen' => ignored_prescreens }
  end

  def save_event
    events = self.patient.events.where( class_name: self.class.name, class_id: self.id ).to_a

    events.delete(self.patient.find_or_create_event(self.class.name, self.id, self.visit_at, 'Prescreen'))

    events.each{ |e| e.destroy }
  end

end
