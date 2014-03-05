class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name,
  #                 :task_tracker_screen_token

  # Callbacks
  after_create :notify_system_admins

  # Concerns
  include Contourable, Deletable

  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}

  # Named Scopes
  scope :status, lambda { |arg| where( status: arg ) }
  scope :search, lambda { |arg| where( 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ) }
  scope :with_call, -> {  where( "users.id in (select DISTINCT(calls.user_id) from calls)" ) }

  # Model Validation
  validates_presence_of     :first_name
  validates_presence_of     :last_name

  # Model Relationships
  has_many :authentications
  has_many :calls, -> { where deleted: false }
  has_many :choices, -> { where deleted: false }
  has_many :clinics, -> { where deleted: false }
  has_many :doctors, -> { where deleted: false }
  has_many :evaluations, -> { where deleted: false }
  has_many :mailings, -> { where deleted: false }
  has_many :patients, -> { where deleted: false }
  has_many :prescreens, -> { where deleted: false }
  has_many :visits, -> { where deleted: false }

  # User Methods

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(self.email.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super and self.status == 'active' and not self.deleted?
  end

  def destroy
    super
    update_column :status, 'inactive'
    update_column :updated_at, Time.now
  end

  # def email_on?(value)
  #   [nil, true].include?(self.email_notifications[value.to_s])
  # end

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  # Override of Contourable
  def apply_omniauth(omniauth)
    unless omniauth['info'].blank?
      self.first_name = omniauth['info']['first_name'] if first_name.blank?
      self.last_name = omniauth['info']['last_name'] if last_name.blank?
    end
    super
  end

  private

  def notify_system_admins
    User.current.where(system_admin: true).each do |system_admin|
      UserMailer.notify_system_admin(system_admin, self).deliver if Rails.env.production?
    end
  end
end
