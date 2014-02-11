class HandlerResource < ActiveRecord::Base
  acts_as_versionable
  
  def after_accepting_anything
    increment(:accept_count)
    save
  end

  def after_accepting_an_initial_version
    update_attribute(:accepted, true)
  end

  def after_accepting_a_revision
    increment(:accepted_revisions_count)
    save
  end
  
  def after_declining_anything
    increment(:decline_count)
    save
  end

  def after_declining_an_initial_version
    update_attribute(:declined, true)
  end

  def after_declining_a_revision
    increment(:declined_revisions_count)
    save
  end
end
