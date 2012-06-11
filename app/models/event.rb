class Event < ActiveRecord::Base

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["events.patient_id in (select patients.id from patients where LOWER(patients.mrn) LIKE (?) or LOWER(patients.subject_code) LIKE (?) or
                                                                                                                 LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?) or
                                                                                                                 LOWER(patients.phone_home) LIKE (?) or LOWER(patients.phone_day) LIKE (?) or LOWER(patients.phone_alt) LIKE (?))", args.first.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }
  scope :with_patient, lambda { |*args| { conditions: ["events.patient_id LIKE ?", args.first] } }
  scope :subject_code_not_blank, conditions: ["events.patient_id in (select patients.id from patients where patients.subject_code != '')"]

  # Model Validation
  validates_presence_of :patient_id, :event_time

  # Model Relationships
  belongs_to :patient, conditions: { deleted: false }, touch: true

  # Class Methods

  def month_year
    { display: self.event_time.strftime('%B') + (self.event_time.year == Date.today.year ? "" : " #{self.event_time.year}" ), id: self.event_time.strftime("%m%Y") }
  end

  def full_name
    if object.class.name == 'Evaluation'
      "#{object.evaluation_type_name} #{object.administration_type_name} #{self.name}"
    elsif object.class.name == 'Visit'
      "#{object.visit_type_name} #{self.name}"
    elsif object.class.name == 'Call'
      "#{object.call_type_name} #{self.name}"
    else
      self.name
    end
  end

  def use_date?
    ['Evaluation', 'Mailing', 'Visit'].include?(object.class.name)
  end

  def object
    self.class_name.constantize.find_by_id(self.class_id)
  end

  def destroy
    update_attribute :deleted, true
    # Does not make sense to delete the object if only one of its events is deleted.
    # object = self.class_name.constantize.find_by_id(self.class_id)
    # object.destroy if object and not object.deleted?
  end

  def image
    case class_name when 'Mailing'
      'mail'
    when 'Call'
      'phone_1'
    when 'Evaluation'
      'cert'
    when 'Visit'
      'users'
    else # 'Prescreen'
      '3x3_grid'
    end
  end

end
