class ChangeTracker::Attribute

  attr_reader :attr
  def initialize(attr)
    @attr = attr
  end

  def name
    attr.name
  end

  def old_value
    attr.old_value
  end

  def new_value
    attr.new_value
  end

end