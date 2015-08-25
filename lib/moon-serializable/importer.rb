require 'moon-serializable/serializer'

module Moon
  module Serializable
    # Serializer for importing objects
    class Importer < Serializer
      # @param [String] klass_path  name of the class, or its pathe to import
      # @param [String, Symbol] key  data key (debug)
      # @param [Hash<String, Object>] value  data to import in the class
      # @param [Integer] depth  recursion depth (debug)
      # @return [Object] instance of the class imported
      private def import_class(klass_path, key, value, depth = 0)
        Object.const_get(klass_path).load(value, depth + 1)
      end

      # @param [String, Symbol] key  data key (debug)
      # @param [Object] value  data to import
      # @param [Integer] depth  recursion depth (debug)
      # @return [Object] imported object
      def import_object(key, value, depth = 0)
        if value.is_a?(Array)
          value.map { |v| import_object(key, v, depth + 1) }
        elsif value.is_a?(Hash)
          if value.key?('&class')
            data = value.dup
            klass = data.delete('&class')
            import_class(klass, key, data, depth + 1)
          else
            value.map { |k, v| [k, import_object(k, v, depth + 1)] }.to_h
          end
        else
          value
        end
      end

      # @param [#exported_properties, #[]=] target
      # @param [#[]] data
      # @param [Integer] depth  recursion depth (debug)
      def import(target, data, depth = 0)
        target.exported_properties do |key, _|
          obj_data = data[key.to_s]
          obj = import_object(key, obj_data, depth + 1)
          target.property_set(key, obj)
        end
        target
      end

      # @param [#exported_properties, #[]=] target
      # @param [#[]] data
      # @param [Integer] depth
      def self.import(target, data, depth = 0)
        new.import(target, data, depth + 1)
      end
    end
  end
end
