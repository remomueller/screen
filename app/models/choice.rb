class Choice < ActiveRecord::Base
  attr_accessible :category, :name, :description, :color, :included_fields

  CATEGORIES = ['exclusion', 'participation', 'risk factors', 'evaluation type', 'administration type', 'visit type', 'visit outcome', 'call type', 'call response'].collect{|i| [i,i]}

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(name) LIKE ? or LOWER(category) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :category, :user_id
  validates_uniqueness_of :name, scope: :category

  # Model Relationships
  has_and_belongs_to_many :prescreens
  has_and_belongs_to_many :mailings
  belongs_to :user

  # Class Methods
  def destroy
    update_column :deleted, true
  end

  def fields
    included_fields.gsub(/[^\w,\s]/, '').split(/[,\s]/).select{|i| not i.blank?}
  end

end
