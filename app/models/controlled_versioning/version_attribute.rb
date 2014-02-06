module ControlledVersioning
  class VersionAttribute < ActiveRecord::Base

    belongs_to :version, polymorphic: true

    validates :name, presence: true
  end
end
