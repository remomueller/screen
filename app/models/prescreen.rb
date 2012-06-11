class Prescreen < ActiveRecord::Base

  VALID_AGE = defined?(RULE_AGE) ? RULE_AGE : ()
  EDITABLES = ['eligibility', 'exclusion']
  RISK_FACTORS = defined?(RULE_RISK_FACTORS) ? RULE_RISK_FACTORS : []

  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible']]

  # Callbacks
  after_save :save_event

  # Named Scopes
  scope :current, conditions: ["prescreens.deleted = ? and prescreens.patient_id IN (select patients.id from patients where patients.deleted = ?)", false, false]
  scope :with_mrn, lambda { |*args| { conditions: ["prescreens.patient_id in (select patients.id from patients where LOWER(patients.mrn) LIKE (?) or LOWER(patients.subject_code) LIKE (?) or
                                                                                                                     LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?) or
                                                                                                                     LOWER(patients.phone_home) LIKE (?) or LOWER(patients.phone_day) LIKE (?) or LOWER(patients.phone_alt) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }
  scope :with_eligibility, lambda { |*args| { conditions: ["prescreens.eligibility IN (?)", args.first] } }
  scope :subject_code_not_blank, conditions: ["prescreens.patient_id in (select patients.id from patients where patients.subject_code != '')"]
  scope :visit_before, lambda { |*args| { conditions: ["prescreens.visit_at < ?", (args.first+1.day).at_midnight]} }
  scope :visit_after, lambda { |*args| { conditions: ["prescreens.visit_at >= ?", args.first.at_midnight]} }
  scope :with_no_calls, lambda { |*args| { conditions: ["prescreens.patient_id not in (select DISTINCT(calls.patient_id) from calls)"]} }

  # Model Validation
  validates_presence_of :clinic_id
  validates_presence_of :doctor_id
  validates_presence_of :patient_id
  validates_presence_of :visit_at, message: 'date and time can\'t be blank'

  # Model Relationships
  belongs_to :clinic, conditions: { deleted: false }
  belongs_to :doctor, conditions: { deleted: false }
  belongs_to :patient, conditions: { deleted: false }, touch: true
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
    update_attribute :deleted, true
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, self.visit_at, 'Prescreen')
    event.update_attribute :deleted, true if event
  end

  # Tab delimited
  # Ignore Potential Header Row...
  # Time  Status  Clinic  Patient Name  Sex/Age MRN Visit Type  Reason for Visit  PG
  # Includes "Appointment Date"
  # Includes Cardiologist
  def self.process_bulk(params, current_user)
    prescreens = Prescreen.current.count
    ignored_prescreens = 0
    doctors = Doctor.current.count
    clinics = Clinic.current.count
    doctor_name = ''
    appointment_date = Date.strptime(params[:visit_date], "%m/%d/%Y") rescue Date.today
    # gsub(/\u00a0/, ' ') This replaces non-breaking whitespace
    params[:tab_dump].gsub(/\u00a0/, ' ').split(/\r|\n/).each_with_index do |row, row_index|
      row = row.strip
      unless row.blank?
        row_array = row.split(/\t/)
        doctor_name = row_array.first if row_array.size == 1
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

          clinic = Clinic.find_or_create_by_name(clinic_name)
          clinic.update_attribute :user_id, current_user.id unless clinic.user
          doctor = Doctor.find_or_create_by_name_and_doctor_type(doctor_name, 'cardiologist')
          doctor.update_attribute :user_id, current_user.id unless doctor.user

          if (Prescreen::VALID_AGE.blank? or Prescreen::VALID_AGE.include?(age)) and not doctor.blacklisted? and not clinic.blacklisted? and not mrn.blank?
            patient = Patient.find_or_create_by_mrn(mrn)
            patient.update_attribute :user_id, current_user.id unless patient.user
            patient.update_attributes(first_name: first_name, last_name: last_name, sex: sex, age: age)
            prescreen = patient.prescreens.find_or_create_by_visit_at_and_clinic_id_and_doctor_id(time_start, clinic.id, doctor.id)
            prescreen.update_attribute :user_id, current_user.id unless prescreen.user
            prescreen.update_attributes(visit_duration: minutes, visit_units: 'minutes')
          else
            ignored_prescreens += 1
          end
        end
      end
    end

    { prescreen: Prescreen.current.count - prescreens, doctor: Doctor.current.count - doctors, clinic: Clinic.current.count - clinics, 'ignored prescreen' => ignored_prescreens }
  end

  def save_event
    events = self.patient.events.find_all_by_class_name_and_class_id(self.class.name, self.id)

    event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, self.visit_at, 'Prescreen')
    events = events - [event]

    events.each{ |e| e.destroy }
  end
end
