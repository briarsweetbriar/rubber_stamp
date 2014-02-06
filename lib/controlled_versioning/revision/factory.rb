class Revision::Factory < Revision

  attr_reader :versionable, :version
  def initialize(args)
    @versionable = args[:versionable]
    @version = args[:version]
  end

  def build
    mark_for_removal
    add_notes
    build_attributes
    build_children
  end

  private
  def mark_for_removal
    version.marked_for_removal = true if versionable.marked_for_destruction?
  end

  def add_notes
    unless versionable_is_a_nested_association?
      version.notes = versionable_notes
      version.user = versionable_user
    end
  end

  def build_attributes
    versionable_attributes.each do |attr|
      attr = AttributeEncapsulator.new(attr)
      if versionable_changed_attributes.include?(attr.key)
        build_attribute(attr)
      end
    end
  end

  def build_attribute(attr)
    version_attributes.build(
      name: attr.key,
      new_value: attr.value,
      old_value: previous_value(attr.key))
  end

  def build_children
    versionable_nested_associations.each do |association|
      versionable.public_send(association).each do |child|
        build_child(child)
      end
    end
  end

  def build_child(child)
    if Revision::Auditor.new(child).changes_original?
      version_child = build_version_child(child)
      Revision::Factory.new(versionable: child, version: version_child).build
    end
  end

  def build_version_child(child)
    if child.new_record?
      version_children.build(versionable_type: child.class.name)
    else
      version_children.build(versionable: child)
    end
  end

end