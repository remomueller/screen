class Patient < ActiveRecord::Base
  EDITABLES = ['phone_home', 'address1']

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_mrn, lambda { |*args| { conditions: ["LOWER(patients.mrn) LIKE (?) or LOWER(patients.first_name) LIKE (?) or LOWER(patients.last_name) LIKE (?)", args.first.downcase.to_s + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%'] } }

  # Model Validation
  # validates_presence_of     :first_name
  # validates_presence_of     :last_name
  validates_presence_of     :mrn
  validates_uniqueness_of   :mrn

  # Model Relationships
  has_many :events, conditions: { deleted: false }
  has_many :mailings, conditions: { deleted: false }
  has_many :prescreens, conditions: { deleted: false }

  # Class Methods

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def address
    [self.address1, self.city, self.state, self.zip].select{|i| not i.blank?}.join(', ')
  end

end
