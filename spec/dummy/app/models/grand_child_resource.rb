class GrandChildResource < ActiveRecord::Base
  acts_as_versionable nested_within: :child_resource
  
  belongs_to :child_resource
end
