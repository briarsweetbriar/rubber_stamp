class ChangeCounter
  
  attr_accessor :version
  def initialize(version)
    @version = version
  end

  def count
    version.version_attributes.length + changed_child_attributes
  end

  private
  def changed_child_attributes
    version.version_children.collect{ |child| ChangeCounter.new(child).count }.
      inject(:+) || 0
  end

end