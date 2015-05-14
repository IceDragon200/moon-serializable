require 'moon-serializable/importer'
require 'moon-serializable/exporter'

module Moon
  # Mixin for defining serializable data, see {Serializable::Importer} and
  # {Serializable::Exporter} setting up a Serializable object
  module Serializable
    # Serializable instance methods.
    module InstanceMethods
      # @return [Hash<String, Object>]
      private def serialization_export_header
        {
          '&class' => self.class.to_s
        }
      end

      # Imports the given data into the object, this will strip
      # the `&class` meta key from the data before passing it to the Importer.
      #
      # @param [Hash<String, Object>] data
      # @param [Integer] depth  depth tracking
      # @return [self]
      private def import_headless(data, depth = 0)
        import_data = data.dup
        import_data.delete('&class')
        Importer.import self, import_data, depth
        self
      end

      # Imports the provided data into the object
      #
      # @param [Hash<String, Object>] data
      # @param [Integer] depth  depth tracking
      # @return [self]
      def import(data, depth = 0)
        import_headless data, depth
        self
      end

      # Exports the object as a Hash, all keys are expected to be strings.
      #
      # @param [Integer] depth
      # @return [Hash<String, Object>]
      def export(data = nil, depth = 0)
        data = Exporter.export(data || {}, self, depth)
        data.merge!(serialization_export_header).stringify_keys
      end

      # Makes a copy of the Object using the .load and #export methods
      # This should not be confused with deep_clone, which uses Marshal.
      #
      # @return [Object]  copy of the object
      def copy
        self.class.load export
      end
    end

    # Serializable class methods.
    module ClassMethods
      # Creates a new instance of the object and {InstanceMethods#import}s
      # the data into it.
      # You can overwrite this method in your own class in case your object
      # cannot be initialized without parameters.
      #
      # @param [Hash<String, Object>] data
      # @return [Object] instance of the class
      def load(data, depth = 0)
        new.import(data, depth)
      end
    end

    # @param [Module] mod
    def self.included(mod)
      mod.extend         ClassMethods
      mod.send :include, InstanceMethods
    end
  end
end
