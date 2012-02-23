class Prescreen < ActiveRecord::Base
  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  # validates_presence_of     :first_name
  # validates_presence_of     :last_name

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }

  # Class Methods

  def event_at
    self.visit_at
  end

  # Tab delimited
  # Ignore Potential Header Row...
  # Time  Status  Clinic  Patient Name  Sex/Age MRN Visit Type  Reason for Visit  PG
  # Includes "Appointment Date"
  # Includes Cardiologist
  def self.process_bulk(params)
    prescreens = Prescreen.count
    cardiologist = ''
    appointment_date = Date.strptime(params[:visit_date], "%m/%d/%Y") rescue Date.today
    params[:tab_dump].split(/\r|\n/).each_with_index do |row, row_index|
      row = row.strip
      unless row.blank?
        row_array = row.split(/\t/)
        cardiologist = row_array.first if row_array.size == 1
        if not cardiologist.blank? and row_array.size > 1
          Rails.logger.debug row_array
          time = row_array[0]
          time_start = Time.zone.parse(appointment_date.strftime('%Y-%m-%d') + ' ' + time.split(' - ').first)
          time_end = Time.zone.parse(appointment_date.strftime('%Y-%m-%d') + ' ' + time.split(' - ').last)
          minutes = ((time_end - time_start) / 1.minute).to_i
          clinic = row_array[2]
          name = row_array[3]
          last_name = name.split(',').first.strip
          first_name = name.split(',')[1..-1].join(',').strip
          sex_age = row_array[4]
          sex = sex_age.split(' ').first
          age = sex_age.split(' ')[1..-1].join(' ')
          mrn = row_array[5]
          reason_for_visit = row_array[6]
          comment = row_array[7]
          patient = Patient.find_or_create_by_mrn(mrn)
          patient.update_attributes(first_name: first_name, last_name: last_name, sex: sex, age: age)
          prescreen = patient.prescreens.find_or_create_by_visit_at(time_start)
          prescreen.update_attributes(clinic: clinic, cardiologist: cardiologist, visit_duration: minutes, visit_units: 'minutes')
          event = patient.events.find_or_create_by_class_name_and_class_id(prescreen.class.name, prescreen.id)
        end
      end
    end
    Prescreen.count - prescreens
  end
end
