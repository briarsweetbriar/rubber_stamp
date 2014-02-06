class GrandChildResource < ActiveRecord::Base
  acts_as_versionable nested_within: :child_resource
  
  belongs_to :child_resource

  validates :r_float, numericality: {less_than_or_equal_to: 100}
end
