class HandlerResource < ActiveRecord::Base
  acts_as_versionable
  
  def when_accepting_anything
    increment(:accept_count)
    save
  end

  def when_accepting_an_initial_version
    update_attribute(:accepted, true)
  end

  def when_accepting_a_revision
    increment(:accepted_revisions_count)
    save
  end
  
  def when_declining_anything
    increment(:decline_count)
    save
  end

  def when_declining_an_initial_version
    update_attribute(:declined, true)
  end

  def when_declining_a_revision
    increment(:declined_revisions_count)
    save
  end
end
