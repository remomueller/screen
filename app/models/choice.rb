class Choice < ActiveRecord::Base
  # attr_accessible :category, :name, :description, :color, :included_fields

  CATEGORIES = ['exclusion', 'participation', 'risk factors', 'evaluation type', 'administration type', 'visit type', 'visit outcome', 'call type', 'call response'].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where( 'LOWER(name) LIKE ? or LOWER(category) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ) }

  # Model Validation
  validates_presence_of :name, :category, :user_id
  validates_uniqueness_of :name, scope: :category

  # Model Relationships
  has_and_belongs_to_many :prescreens
  has_and_belongs_to_many :mailings
  belongs_to :user

  # Class Methods
  def fields
    included_fields.gsub(/[^\w,\s]/, '').split(/[,\s]/).select{|i| not i.blank?}
  end

end
