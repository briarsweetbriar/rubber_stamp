class Revision::Factory < Revision

  attr_reader :versionable, :suggested_attributes
  attr_accessor :version
  def initialize(args)
    @versionable = args[:versionable]
    @version = args[:version]
    @suggested_attributes = args[:suggested_attributes]
  end

  def build_parent
    versionable.assign_attributes(suggested_attributes)
    if versionable.invalid?
      versionable.errors
    elsif !Revision::Auditor.new(versionable).changes_original?
      versionable.errors[:base] << I18n.t("errors.messages.no_revisions_made")
      versionable.errors
    else
      self.version = versionable.versions.build
      add_notes
      build_associations
      version.save
      version
    end
  end

  def build_associations
    mark_for_removal
    build_attributes
    build_children
  end

  private
  def add_notes
    version.notes = versionable_notes
    version.user = versionable_user
  end

  def mark_for_removal
    version.marked_for_removal = true if versionable.marked_for_destruction?
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
        build_child(child, association)
      end
    end
  end

  def build_child(child, association)
    if Revision::Auditor.new(child).changes_original?
      version_child = build_version_child(child, association)
      Revision::Factory.new(
        versionable: child,
        version: version_child
      ).build_associations
    end
  end

  def build_version_child(child, association)
    version_child = version_children.build(association_name: association)
    version_child.versionable = child unless child.new_record?
    version_child
  end

end