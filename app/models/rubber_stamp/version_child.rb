module RubberStamp
  class VersionChild < ActiveRecord::Base

    belongs_to :versionable, polymorphic: true
    belongs_to :version, polymorphic: true
    has_many :version_attributes, as: :version
    has_many :version_children, as: :version

    def revisions
      ChangeTracker.new(self)
    end

    def parent
      version
    end

    def is_a_child?
      true
    end
  end
end
