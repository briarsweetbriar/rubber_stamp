class Revision < Version

  private
  def versionable_changed_attributes
    versionable.changed_attributes
  end

  def versionable_changes(key)
    values = versionable.changes[key]
    ValueChange.new(values[0], values[1])
  end

  def previous_value(key)
    versionable_changes(key).previous_value
  end

  ValueChange = Struct.new(:previous_value, :new_value)
end