class InitialVersion::Factory < InitialVersion

  attr_reader :versionable, :version
  def initialize(versionable)
    @versionable = versionable
    @version = build_version_type
  end

  def build
    build_version_attributes
    version.save
  end

  private
  def build_version_type
    if versionable_is_a_nested_association?
      versionable_parent.initial_version.version_children.
        build(versionable: versionable)
    else
      versionable.versions.build(initial: true, notes: versionable_notes, user:
        versionable_user)
    end
  end

  def build_version_attributes
    versionable_attributes.each do |attr|
      attr = AttributeEncapsulator.new(attr)
      build_attribute(attr)
    end
  end

  def build_attribute(attr)
    version_attributes.build(
      name: attr.key,
      new_value: attr.value)
  end

end