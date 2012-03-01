class Doctor < ActiveRecord::Base

  # Callbacks
  after_save :check_blacklisted

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name
  validates_uniqueness_of :name

  # Model Relationships
  has_many :prescreens, conditions: { deleted: false }

  # Class Methods
  def destroy
    update_attribute :deleted, true
  end

  def blacklisted?
    status == 'blacklist'
  end

  # Destroy all associated prescreens if doctor is blacklisted
  def check_blacklisted
    prescreens.destroy_all if self.blacklisted?
  end

  def self.doctor_select
    [['---Whitelist---', nil]] + Doctor.current.where("status != 'blacklist' or status IS NULL").order('name').collect{ |d| [d.name, d.id] } + [['',nil],['---Blacklist---', nil]] + Doctor.current.where(status: 'blacklist').order('name').collect{ |d| [d.name, d.id] }
  end

end
