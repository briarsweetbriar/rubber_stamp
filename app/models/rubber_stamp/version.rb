module RubberStamp
  class Version < ActiveRecord::Base

    belongs_to :versionable, polymorphic: true
    belongs_to :user
    has_many :version_attributes, as: :version
    has_many :version_children, as: :version

    scope :pending, -> { where(pending: true) }
    scope :accepted, -> { where(accepted: true) }
    scope :declined, -> { where(declined: true) }

    def accept(&block)
      if pending?
        versionable.reload
        Revision::Publisher.new(self).accept_revision unless initial?
        update_attributes(pending: false, accepted: true, accepted_at: DateTime.current)
        block.call(self) if block_given?
      end
    end

    def decline(&block)
      if pending?
        versionable.reload
        update_attributes(pending: false, declined: true)
        block.call(self) if block_given?
      end
    end

    def changed_attributes_count
      ChangeCounter.new(self).count
    end

    def revisions
      ChangeTracker.new(self)
    end

    def is_a_child?
      false
    end
  end
end
