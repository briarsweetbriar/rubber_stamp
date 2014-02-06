class PartiallyExclusiveVersionableResource < ActiveRecord::Base
  acts_as_versionable nonversionable_attributes: ["r_boolean", :r_date]
end
