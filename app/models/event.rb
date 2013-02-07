class Event < ActiveRecord::Base
  attr_accessible :patient_id, :class_name, :class_id, :event_time, :name

  # Concerns
  include Patientable

  # Named Scopes
  scope :with_patient, lambda { |*args| { conditions: ["events.patient_id LIKE ?", args.first] } }

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
    update_column :deleted, true
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
