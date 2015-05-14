require 'moon-serializable/importer'
require 'moon-serializable/exporter'

module Moon
  module Serializable
    module InstanceMethods
      # @abstract
      # @yield [Array[Symbol, Object]]
      # :exported_properties

      # @return [Hash<String, Object>]
      private def serialization_export_header
        {
          '&class' => self.class.to_s
        }
      end

      private def import_headless(data, depth = 0)
        import_data = data.dup
        import_data.delete('&class')
        Importer.import self, import_data, depth
      end

      # @param [Hash<[String, Symbol], Object>] data
      # @param [Integer] depth
      def import(data, depth = 0)
        import_headless data, depth
      end

      # @param [Integer] depth
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

    module ClassMethods
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
