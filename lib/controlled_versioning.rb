require "controlled_versioning/engine"

# Core
require "controlled_versioning/version"

require "controlled_versioning/change_tracker"
require "controlled_versioning/change_tracker/attribute"
require "controlled_versioning/change_tracker/child"

require "controlled_versioning/initial_version"
require "controlled_versioning/initial_version/factory"

require "controlled_versioning/revision"
require "controlled_versioning/revision/auditor"
require "controlled_versioning/revision/factory"
require "controlled_versioning/revision/publisher"

# Add utility classes
require "support/array_converter"
require "support/attribute_encapsulator"

module ControlledVersioning
  module ActsAsVersionable
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      def acts_as_versionable(options = {})

        send :include, InstanceMethods

        def define_callbacks(*types)
          types.each { |type| define_callback(type) }
        end

        def define_callback(type)
          define_singleton_method("after_#{type}_a_version") do |*args|
            options = args.extract_options!
            options.merge!(only: :general) if options[:only].blank?
            register_callback_methods(type, args, options)
          end
        end

        def register_callback_methods(type, args, options)
          restriction = options[:only].to_s
          define_singleton_method("#{restriction}_#{type}_callbacks") do
            args
          end
        end

        define_callbacks :creating, :accepting, :declining

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
                   class_name: 'ControlledVersioning::VersionChild',
                   as: :versionable
        else
          has_many :versions,
                   lambda { order("created_at ASC")},
                   class_name: 'ControlledVersioning::Version',
                   as: :versionable
        end

        cattr_accessor :versionable_attribute_names
        self.versionable_attribute_names = options[:versionable_attributes] ||
                                           set_versionable_attribute_names(
                                           options[:nonversionable_attributes])
        
        def new_with_version(attributes)
          resource = self.new(attributes)
          return resource.errors if resource.invalid?
          resource.build_initial_version
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

ActiveRecord::Base.send :include, ControlledVersioning::ActsAsVersionable