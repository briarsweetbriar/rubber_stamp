module ControlledVersioning
  class Version < ActiveRecord::Base
    belongs_to :versionable, polymorphic: true
    belongs_to :user
    has_many :version_attributes, as: :version
    has_many :version_children, as: :version

    scope :pending, -> { where(pending: true) }
    scope :accepted, -> { where(accepted: true) }
    scope :declined, -> { where(declined: true) }

    after_create :run_user_generated_create_callbacks

    def accept
      if pending?
        versionable.reload
        Revision::Publisher.new(self).accept_revision unless initial?
        update_attributes(pending: false, accepted: true)
        trigger_callbacks(:general_accepting_callbacks)
        trigger_callbacks(:initial_accepting_callbacks) if initial?
        trigger_callbacks(:revision_accepting_callbacks) unless initial?
      end
    end

    def decline
      if pending?
        versionable.reload
        update_attributes(pending: false, declined: true)
        trigger_callbacks(:general_declining_callbacks)
        trigger_callbacks(:initial_declining_callbacks) if initial?
        trigger_callbacks(:revision_declining_callbacks) unless initial?
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

    private
    def run_user_generated_create_callbacks
      trigger_callbacks(:general_creating_callbacks)
      trigger_callbacks(:initial_creating_callbacks) if initial?
      trigger_callbacks(:revision_creating_callbacks) unless initial?
    end

    def trigger_callbacks(type)
      if versionable.class.respond_to?(type)
        callbacks = versionable.class.send(type)
        callbacks.each do |callback|
          send_callback(callback)
        end
      end
    end

    def send_callback(callback)
      if versionable.method(callback).parameters.length > 0
        versionable.send(callback, self)
      else
        versionable.send(callback)
      end
    end
  end
end
