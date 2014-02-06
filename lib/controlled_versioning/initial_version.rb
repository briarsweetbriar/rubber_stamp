class InitialVersion < Version

  private
  def versionable_nested_within
    versionable.nested_within
  end

  def versionable_parent
    versionable.public_send(versionable_nested_within)
  end
end