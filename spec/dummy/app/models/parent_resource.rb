class ParentResource < ActiveRecord::Base
  acts_as_versionable

  has_many :child_resources

  accepts_nested_attributes_for :child_resources, allow_destroy: true

  validates :r_float, numericality: {less_than_or_equal_to: 100}
end
