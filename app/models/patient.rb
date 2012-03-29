class Patient < ActiveRecord::Base
  EDITABLES = ['phone_home', 'city', 'state']

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["LOWER(patients.mrn) LIKE (?) or LOWER(patients.subject_code) LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?)", args.first.downcase.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }
  scope :subject_code_not_blank, conditions: ["patients.subject_code != ''"]
  scope :with_priority_message, lambda { |*args| { conditions: ["patients.priority_message LIKE ?", "%" + args.first + "%"] } }

  # Model Validation
  validates_presence_of :mrn, if: :no_subject_code?
  validates_uniqueness_of :mrn, allow_blank: true
  validates_presence_of :subject_code, if: :no_mrn?
  validates_uniqueness_of :subject_code, allow_blank: true

  # Model Relationships
  has_many :calls, conditions: { deleted: false }
  has_many :evaluations, conditions: { deleted: false }
  has_many :events, conditions: { deleted: false }
  has_many :mailings, conditions: { deleted: false }
  has_many :prescreens, conditions: { deleted: false }
  has_many :visits, conditions: { deleted: false }
  belongs_to :user

  # Class Methods

  # Study Code if available, if not, MRN

  def editable_by?(current_user)
    current_user.screener? or (not self.subject_code.blank? and current_user.subject_handler?)
  end

  def code
    self.subject_code.blank? ? self.mrn : self.subject_code
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

  def destroy
    update_attribute :deleted, true
  end

  def no_subject_code?
    self.subject_code.blank?
  end

  def no_mrn?
    self.mrn.blank?
  end

  def berlin_from_calls_and_mailings
    (self.calls.pluck(:berlin) + self.mailings.pluck(:berlin)).compact.uniq
  end

  def ess_from_calls_and_mailings
    (self.calls.pluck(:ess) + self.mailings.pluck(:ess)).compact.uniq
  end
end
