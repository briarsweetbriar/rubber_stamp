module ControlledVersioning
  class Version < ActiveRecord::Base
    belongs_to :versionable, polymorphic: true
    belongs_to :user
    has_many :version_attributes, as: :version
    has_many :version_children, as: :version

    scope :pending, -> { where(pending: true) }
    scope :accepted, -> { where(accepted: true) }
    scope :declined, -> { where(declined: true) }

    after_create :run_user_generated_callbacks

    def accept
      if pending?
        Revision::Publisher.new(self).accept_revision unless initial?
        update_attributes(pending: false, accepted: true)
        versionable.try(:after_accepting_anything)
        versionable.try(:after_accepting_an_initial_version) if initial?
        versionable.try(:after_accepting_a_revision) unless initial?
      end
    end

    def decline
      if pending?
        update_attributes(pending: false, declined: true)
        versionable.try(:after_declining_anything)
        versionable.try(:after_declining_an_initial_version) if initial?
        versionable.try(:after_declining_a_revision) unless initial?
      end
    end

    def revisions
      ChangeTracker.new(self)
    end

    def is_a_child?
      false
    end

    private
    def run_user_generated_callbacks
      versionable.try(:after_creating_anything)
      versionable.try(:after_creating_an_initial_version) if initial?
      versionable.try(:after_creating_a_revision) unless initial?
    end
  end
end
