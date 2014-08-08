class Revision::Auditor < Revision

  attr_reader :versionable
  def initialize(versionable)
    @versionable = versionable
  end

  def changes_original?
    return true if versionable.marked_for_destruction? ||
                   changes_at_least_one_attribute? ||
                   changes_at_least_one_nested_association?
    return false
  end

  private
  def changes_at_least_one_attribute?
    versionable_attributes.each do |attr|
      attr = AttributeEncapsulator.new(attr)
      return true if versionable_changed_attributes.include?(attr.key)
    end
    return false
  end

  def changes_at_least_one_nested_association?
    versionable_nested_associations.each do |association|
      return true if association_changed?(association)
    end
    return false
  end

  def association_changed?(association)
    versionable.public_send(association).each do |child|
      return true if child_changed?(child)
    end
    return false
  end

  def child_changed?(child)
    child.new_record? || child.marked_for_destruction? ||
      Revision::Auditor.new(child).changes_original?
  end
end