module RubberStamp
  class VersionAttribute < ActiveRecord::Base

    belongs_to :version, polymorphic: true
    has_many :diff_attributes

    validates :name, presence: true
  end
end
