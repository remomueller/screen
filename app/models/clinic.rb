class Clinic < ActiveRecord::Base

  # Callbacks
  after_save :check_blacklisted

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name
  validates_uniqueness_of :name

  # Model Relationships
  has_many :prescreens, conditions: { deleted: false }
  belongs_to :user

  # Class Methods
  def destroy
    update_attribute :deleted, true
  end

  def blacklisted?
    status == 'blacklist'
  end

  # Destroy all associated prescreens if clinic is blacklisted
  def check_blacklisted
    prescreens.destroy_all if self.blacklisted?
  end

  def self.clinic_select
    [['---Whitelist---', nil]] + Clinic.current.where("status != 'blacklist' or status IS NULL").order('name').collect{ |c| [c.name, c.id] } + [['',nil],['---Blacklist---', nil]] + Clinic.current.where(status: 'blacklist').order('name').collect{ |c| [c.name, c.id] }
  end

end
