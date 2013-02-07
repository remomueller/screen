class Clinic < ActiveRecord::Base
  attr_accessible :name, :status, :user_id

  # Callbacks
  after_save :check_blacklisted

  # Concerns
  include Deletable, Searchable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :user_id
  validates_uniqueness_of :name, scope: :deleted

  # Model Relationships
  has_many :prescreens, conditions: { deleted: false }
  belongs_to :user

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
