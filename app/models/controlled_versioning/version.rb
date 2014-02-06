module ControlledVersioning
  class Version < ActiveRecord::Base
    belongs_to :versionable, polymorphic: true
    belongs_to :user
    has_many :version_attributes, as: :version
    has_many :version_children, as: :version

    validates :versionable, presence: true

    scope :pending, -> { where(pending: true) }
    scope :accepted, -> { where(accepted: true) }
    scope :declined, -> { where(declined: true) }

    def accept
      Revision::Publisher.new(self).accept_revision unless initial?
      update_attributes(pending: false, accepted: true)
    end

    def decline
      update_attributes(pending: false, declined: true)
    end
  end
end
