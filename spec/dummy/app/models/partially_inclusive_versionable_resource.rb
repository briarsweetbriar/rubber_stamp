class PartiallyInclusiveVersionableResource < ActiveRecord::Base
  acts_as_versionable versionable_attributes: ["r_boolean", :r_date]
end
