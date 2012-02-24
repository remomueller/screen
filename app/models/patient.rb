class Patient < ActiveRecord::Base
  EDITABLES = ['phone', 'address']

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["patients.mrn LIKE (?)", args.first.to_s + '%'] } }

  # Model Validation
  # validates_presence_of     :first_name
  # validates_presence_of     :last_name
  validates_presence_of     :mrn
  validates_uniqueness_of   :mrn

  # Model Relationships
  has_many :events, conditions: { deleted: false }
  has_many :prescreens, conditions: { deleted: false }

  # Class Methods

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

end
