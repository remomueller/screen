module Patientable
  extend ActiveSupport::Concern

  included do
    scope :current, conditions: ["deleted = ? and patient_id IN (select patients.id from patients where patients.deleted = ?)", false, false]
    scope :with_mrn, lambda { |arg| {
      conditions: ["patient_id in (select patients.id from patients where LOWER(patients.mrn)           LIKE ?
                                                                       or LOWER(patients.subject_code)  LIKE ?
                                                                       or LOWER(patients.first_name)    LIKE ?
                                                                       or LOWER(patients.last_name)     LIKE ?
                                                                       or LOWER(patients.phone_home)    LIKE ?
                                                                       or LOWER(patients.phone_day)     LIKE ?
                                                                       or LOWER(patients.phone_alt)     LIKE ?
                                                                       or LOWER(patients.email)         LIKE ?)",
                                                                       arg.to_s.downcase + '%',
                                                                       arg.to_s.downcase.gsub(/^| |$/, '%'),
                                                                       arg.to_s.downcase.gsub(/^| |$/, '%'),
                                                                       arg.to_s.downcase.gsub(/^| |$/, '%'),
                                                                       arg.to_s.downcase.gsub(/^| |$/, '%'),
                                                                       arg.to_s.downcase.gsub(/^| |$/, '%'),
                                                                       arg.to_s.downcase.gsub(/^| |$/, '%'),
                                                                       arg.to_s.downcase.gsub(/^| |$/, '%')] } }
    scope :with_subject_code, lambda { |*args| { conditions: ["patient_id in (select patients.id from patients where LOWER(patients.subject_code) IN (?))", args.first] } }
    scope :subject_code_not_blank, conditions: ["patient_id in (select patients.id from patients where patients.subject_code != '')"]
  end

end
