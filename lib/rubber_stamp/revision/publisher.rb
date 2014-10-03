class Revision::Publisher < Revision

  attr_reader :version, :versionable
  def initialize(version)
    @version = version
    @versionable = version.versionable
  end

  def accept_revision
    create_or_update_versionable
    update_version_children
  end

  private
  def create_or_update_versionable
    versionable.present? ? update_versionable : create_versionable
  end

  def new_attributes
    version_attributes.each_with_object({}) do |version_attribute, hash|
      new_value = if version_attribute.diff_attributes.any?
        Revision::DiffAttribute::Rewinder.new(version_attribute, versionable[version_attribute.name]).recompile
      else
        version_attribute.new_value
      end
      hash[version_attribute.name] = new_value
    end
  end

  def create_versionable
    version.versionable = version.parent.versionable.public_send(
                          version.association_name).create(new_attributes)
  end

  def update_versionable
    versionable.update_columns(new_attributes)
  end

  def update_version_children
    version_children.each do |child|
      update_or_destroy_child(child)
    end
  end

  def update_or_destroy_child(child)
    if child.marked_for_removal?
      destroy_child(child)
    else
      Revision::Publisher.new(child).accept_revision
    end
  end

  def destroy_child(child)
    child.versionable.destroy
  end

end