class InitialVersion::Factory < InitialVersion

  attr_reader :versionable, :version
  def initialize(args)
    @versionable = args[:versionable]
    @version = args[:version]
  end

  def build
    build_version_attributes
    build_children
    version
  end

  private
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

  def build_children
    versionable_nested_associations.each do |association|
      versionable.public_send(association).each do |child|
        build_child(child, association)
      end
    end
  end

  def build_child(child, association)
    version_child = build_version_child(child, association)
    InitialVersion::Factory.new(versionable: child,
      version: version_child).build
  end

  def build_version_child(child, association)
    version_children.build(association_name: association, versionable: child)
  end

end