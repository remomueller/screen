class Mailing < ActiveRecord::Base

  ELIGIBILITY = [['---', nil], ['potentially eligible','potentially eligible'], ['ineligible','ineligible']]

  # Callbacks
  after_save :save_event

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["mailings.patient_id in (select patients.id from patients where LOWER(patients.mrn) LIKE (?) or LOWER(patients.subject_code) LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }
  scope :with_eligibility, lambda { |*args| { conditions: ["mailings.eligibility IN (?)", args.first] } }
  scope :subject_code_not_blank, conditions: ["mailings.patient_id in (select patients.id from patients where patients.subject_code != '')"]
  scope :sent_before, lambda { |*args| { conditions: ["mailings.sent_date < ?", (args.first+1.day)]} }
  scope :sent_after, lambda { |*args| { conditions: ["mailings.sent_date >= ?", args.first]} }

  # Model Validation
  validates_presence_of :patient_id
  validates_presence_of :doctor_id
  validates_presence_of :sent_date

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }, touch: true
  belongs_to :doctor, conditions: { deleted: false }, touch: true
  has_and_belongs_to_many :risk_factors, class_name: 'Choice'
  belongs_to :user

  # Class Methods

  def name
    self.patient ? self.patient.code : self.id
  end

  def participation_name
    (choice = Choice.find_by_id(self.participation)) ? choice.name : ''
  end

  def exclusion_name
    (choice = Choice.find_by_id(self.exclusion)) ? choice.name : ''
  end

  def sent_time
    self.sent_date.blank? ? '' : Time.zone.parse(self.sent_date.to_s + " 00:00:00")
  end

  def response_time
    self.response_date.blank? ? '' : Time.zone.parse(self.response_date.to_s + " 00:00:00")
  end

  def destroy
    update_attribute :deleted, true
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, sent_time, 'Mailing Sent')
    event.update_attribute :deleted, true if event
    event = self.patient.events.find_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, response_time, 'Mailing Response Received')
    event.update_attribute :deleted, true if event
  end

  def save_event
    events = self.patient.events.find_all_by_class_name_and_class_id(self.class.name, self.id)
    unless self.sent_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, sent_time, 'Mailing Sent')
      events = events - [event]
    end
    unless self.response_date.blank?
      event = self.patient.events.find_or_create_by_class_name_and_class_id_and_event_time_and_name(self.class.name, self.id, response_time, 'Mailing Response Received')
      events = events - [event]
    end
    events.each{ |e| e.destroy }
  end

    # Tab delimited
  # Ignores Header Row (since it can't parse the date)
  # Cardiologist  Date of Mailing MRN Last Name First Name  Address1  City  State Zip Code  Home Phone  Day Phone
  def self.process_bulk(params, current_user)
    mailings = Mailing.current.count
    ignored_mailings = 0
    doctors = Doctor.current.count
    doctor_name = ''
    # gsub(/\u00a0/, ' ') This replaces non-breaking whitespace
    params[:tab_dump].gsub(/\u00a0/, ' ').split(/\r|\n/).each_with_index do |row, row_index|
      row = row.strip
      unless row.blank?
        row_array = row.split(/\t/)
        doctor_name = row_array[0]
        sent_date = if row_array[1].to_s.split('/').last.size == 4
          Date.strptime(row_array[1].to_s, "%m/%d/%Y") rescue ""
        else
          Date.strptime(row_array[1].to_s, "%m/%d/%y") rescue ""
        end

        if not doctor_name.blank? and row_array.size > 1 and not sent_date.blank?
          Rails.logger.debug "Gets here"
          mrn = row_array[2].to_s.strip
          last_name = row_array[3].to_s.strip
          first_name = row_array[4].to_s.strip
          address1 = row_array[5].to_s.strip
          city = row_array[6].to_s.strip
          state = row_array[7].to_s.strip
          zip = row_array[8].to_s.strip
          phone_home = row_array[9].to_s.strip
          phone_day = row_array[10].to_s.strip

          doctor = Doctor.find_or_create_by_name_and_doctor_type(doctor_name, 'cardiologist')
          doctor.update_attribute :user_id, current_user.id unless doctor.user

          unless mrn.blank?
            patient = Patient.find_or_create_by_mrn(mrn)
            patient.update_attribute :user_id, current_user.id unless patient.user

            patient_params = { first_name: first_name, last_name: last_name, address1: address1, city: city, state: state, zip: zip, phone_home: phone_home, phone_day: phone_day }
            patient_params.reject!{|key, val| val.blank?}
            patient.update_attributes(patient_params)

            mailing = patient.mailings.find_or_create_by_sent_date_and_doctor_id(sent_date, doctor.id)
            mailing.update_attribute :user_id, current_user.id unless mailing.user
          else
            ignored_mailings += 1
          end
        end
      end
    end

    { mailing: Mailing.current.count - mailings, doctor: Doctor.current.count - doctors, 'ignored mailing' => ignored_mailings }
  end

end
