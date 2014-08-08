class ChangeTracker::Child < ChangeTracker

  attr_reader :version
  def initialize(version)
    @version = version
  end

  def name
    version.association_name
  end

  def marked_for_removal?
    version.marked_for_removal?
  end

  def new?
    version.versionable_id.nil?
  end

end