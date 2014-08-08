class Version

  private
  def versionable_attributes
    versionable.versionable_attributes
  end

  def version_attributes
    version.version_attributes
  end

  def versionable_is_a_nested_association?
    versionable.is_a_nested_association?
  end

  def versionable_nested_associations
    versionable.class.nested_associations
  end

  def version_children
    version.version_children
  end

  def versionable_notes
    versionable.notes
  end

  def versionable_user
    versionable.user
  end
end