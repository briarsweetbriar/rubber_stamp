require "rubber_stamp/engine"

# Core
require "rubber_stamp/version"

require "rubber_stamp/change_counter"

require "rubber_stamp/change_tracker"
require "rubber_stamp/change_tracker/attribute"
require "rubber_stamp/change_tracker/child"

require "rubber_stamp/initial_version"
require "rubber_stamp/initial_version/factory"

require "rubber_stamp/revision"
require "rubber_stamp/revision/auditor"
require "rubber_stamp/revision/factory"
require "rubber_stamp/revision/publisher"

# Add utility classes
require "support/array_converter"
require "support/attribute_encapsulator"

module RubberStamp
  module ActsAsVersionable
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      def acts_as_versionable(options = {})

        send :include, InstanceMethods

        def set_versionable_attribute_names(nonversionables)
          nonversionables = [] unless nonversionables.present?
          ArrayConverter.to_s!(nonversionables)
          nonversionables += ["id", "updated_at", "created_at"]
          attribute_names - nonversionables
        end

        def nested_associations
          nested_attributes_options.keys
        end

        def has_nested_associations?
          nested_associations.present?
        end

        attr_accessor :user, :notes

        cattr_accessor :nested_within
        self.nested_within = options[:nested_within]

        def is_a_nested_association?
          nested_within.present?
        end

        if is_a_nested_association?
          has_many :version_children,
                   class_name: 'RubberStamp::VersionChild',
                   as: :versionable
        else
          has_many :versions,
                   lambda { order("created_at ASC")},
                   class_name: 'RubberStamp::Version',
                   as: :versionable
        end

        cattr_accessor :versionable_attribute_names
        self.versionable_attribute_names = options[:versionable_attributes] ||
                                           set_versionable_attribute_names(
                                           options[:nonversionable_attributes])
        
        def new_with_version(attributes)
          resource = self.new(attributes)
          return resource.errors if resource.invalid?
          initial_version = resource.build_initial_version
          resource
        end

        def create_with_version(attributes)
          resource = new_with_version(attributes)
          resource.save
          resource
        end
      end
    end

    module InstanceMethods
      def is_a_nested_association?
        self.class.is_a_nested_association?
      end

      def versionable_attributes
        versionable_attributes = self.versionable_attribute_names
        ArrayConverter.to_s!(versionable_attributes)
        self.attributes.slice(*versionable_attributes)
      end

      def build_initial_version
        version = versions.build(initial: true, notes: notes, user: user)
        InitialVersion::Factory.new(versionable: self, version: version).build
      end

      def initial_version
        if is_a_nested_association?
          version_children.first
        else
          versions.find_by(initial: true)
        end
      end

      def submit_revision(suggested_attributes)
        Revision::Factory.new(
          versionable: self,
          suggested_attributes: suggested_attributes
        ).build
      end

    end
  end
end

ActiveRecord::Base.send :include, RubberStamp::ActsAsVersionable