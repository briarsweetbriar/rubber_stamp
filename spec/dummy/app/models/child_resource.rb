class ChildResource < ActiveRecord::Base
  acts_as_versionable nested_within: :parent_resource
  
  belongs_to :parent_resource
  has_many :grand_child_resources

  accepts_nested_attributes_for :grand_child_resources
end
