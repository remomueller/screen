class Doctor < ActiveRecord::Base
  attr_accessible :name, :doctor_type, :status, :user_id

  DOCTOR_TYPE = ["cardiologist", "endocrinologist", "somnologist"].collect{|i| [i,i]}

  # Callbacks
  after_save :check_blacklisted

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :doctor_type, :user_id
  validates_uniqueness_of :name, scope: [:doctor_type, :deleted]

  # Model Relationships
  has_many :prescreens, conditions: { deleted: false }
  belongs_to :user

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
