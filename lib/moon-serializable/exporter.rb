require 'moon-serializable/serializer'

module Moon
  module Serializable
    # Serializer for exporting objects
    class Exporter < Serializer
      # Exports the object, Arrays, and Hashes are handled specially,
      # if the object responds to #export, it will export the object with
      # Hash as the target.
      #
      # @param [Symbol] key  the current key being exported on (debug)
      # @param [#export, Array, Hash, Object] value  object to export
      # @param [Integer] depth  recursion depth (debug)
      # @return [Object] exported object
      def export_object(key, value, depth = 0)
        if value.respond_to?(:export)
          value.export({}, depth + 1)
        elsif value.is_a?(Array)
          value.map { |v| export_object(key, v, depth + 1) }
        elsif value.is_a?(Hash)
          value.map { |k, v| [k, export_object(k, v, depth + 1)] }.to_h
        else
          value
        end
      end

      # Exports the provided data, it MUST respond to #exported_properties
      #
      # @param [#[]=] target
      # @param [#exported_properties] data
      # @param [Integer] depth
      # @return [Object] the given target object
      def export(target, data, depth = 0)
        data.exported_properties do |key, value|
          target[key] = export_object(key, value, depth + 1)
        end
        target
      end

      # Creates a new instance of the Exporter and exports the provided
      # data into the target.
      #
      # @param [Object] target  object to import the data in
      # @param [Object] data    object to export the data from
      # @param [Integer] depth  recursion depth (debug)
      def self.export(target, data, depth = 0)
        new.export(target, data, depth + 1)
      end
    end
  end
end
