class VersionableResource < ActiveRecord::Base
  acts_as_versionable

  validates :r_float, numericality: {less_than_or_equal_to: 100}
end
