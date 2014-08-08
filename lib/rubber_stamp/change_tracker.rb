class ChangeTracker < Version

  attr_reader :version
  def initialize(version)
    @version = version
  end

  def all
    attributes + children
  end

  def attributes
    version_attributes.collect{ |attr| ChangeTracker::Attribute.new(attr) }
  end

  def children
    version_children.collect{ |child| ChangeTracker::Child.new(child) }
  end
end