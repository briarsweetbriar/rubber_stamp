module ControlledVersioning
  class Version < ActiveRecord::Base
    belongs_to :versionable, polymorphic: true
    belongs_to :user
    has_many :version_attributes, as: :version
    has_many :version_children, as: :version

    scope :pending, -> { where(pending: true) }
    scope :accepted, -> { where(accepted: true) }
    scope :declined, -> { where(declined: true) }

    def accept
      if pending?
        Revision::Publisher.new(self).accept_revision unless initial?
        update_attributes(pending: false, accepted: true)
      end
    end

    def decline
      update_attributes(pending: false, declined: true) if pending?
    end

    def changes
      ChangeTracker.new(self).get_changes
    end
  end
end
