class Choice < ActiveRecord::Base

  CATEGORIES = ['exclusion', 'participation', 'risk factors'].collect{|i| [i,i]}

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name, :category
  validates_uniqueness_of :name, scope: :category

  # Model Relationships
  has_and_belongs_to_many :prescreens

  # Class Methods
  def destroy
    update_attribute :deleted, true
  end

end
