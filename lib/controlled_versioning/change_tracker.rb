class ChangeTracker < Version

  attr_reader :version
  def initialize(version)
    @version = version
  end

  def get_changes
    changed_attributes.merge(marked_for_removal).merge(changed_children)
  end

  private
  def changed_attributes
    version_attributes.each_with_object({}) do |v, h|
      h[v.name] = { new_value: v.new_value, old_value: v.old_value }
    end
  end

  def marked_for_removal
    version.marked_for_removal? ? { marked_for_removal: true } : {}
  end

  def changed_children
    version_children.each_with_object({}) do |v, h|
      if h[v.association_name].present?
        h[v.association_name] += [{ id: v.versionable_id}.merge(v.changes)]
      else
        h[v.association_name] = [{ id: v.versionable_id}.merge(v.changes)]
      end
    end
  end
end