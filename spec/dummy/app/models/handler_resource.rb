class HandlerResource < ActiveRecord::Base
  acts_as_versionable nonversionable_attributes: [:create_count, :accept_count,
    :decline_count, :created_revisions_count, :accepted_revisions_count,
    :declined_revisions_count, :has_been_created, :accepted, :declined]

  after_creating_a_version :increment_create_count
  after_creating_a_version :created, only: :initial
  after_creating_a_version :increment_created_revision_count,
    only: :revision

  after_accepting_a_version :increment_accept_count
  after_accepting_a_version :accept, only: :initial
  after_accepting_a_version :increment_accepted_revision_count,
    only: :revision

  after_declining_a_version :increment_decline_count
  after_declining_a_version :decline, only: :initial
  after_declining_a_version :increment_declined_revision_count,
    only: :revision

  def increment_create_count
    increment(:create_count)
    save
  end

  def created
    update_attribute(:has_been_created, true)
  end

  def increment_created_revision_count
    increment(:created_revisions_count)
    save
  end

  def increment_accept_count
    increment(:accept_count)
    save
  end

  def accept
    update_attribute(:accepted, true)
  end

  def increment_accepted_revision_count
    increment(:accepted_revisions_count)
    save
  end
  
  def increment_decline_count
    increment(:decline_count)
    save
  end

  def decline
    update_attribute(:declined, true)
  end

  def increment_declined_revision_count
    increment(:declined_revisions_count)
    save
  end
end
