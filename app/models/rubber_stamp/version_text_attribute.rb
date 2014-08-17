module RubberStamp
  class VersionTextAttribute < ActiveRecord::Base

    belongs_to :version_attribute

    scope :deletions, -> { where(deletion: true) }
    scope :insertions, -> { where(deletion: false) }

  end
end
