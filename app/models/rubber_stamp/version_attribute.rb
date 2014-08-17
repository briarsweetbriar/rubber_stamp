module RubberStamp
  class VersionAttribute < ActiveRecord::Base

    belongs_to :version, polymorphic: true
    has_many :version_text_attributes

    validates :name, presence: true
  end
end
