require 'moon-serializable/serializer'

module Moon
  module Serializable
    class Exporter < Serializer
      # @param [Symbol] key
      # @param [Object] value
      # @param [Integer] depth
      private def export_object(key, value, depth = 0)
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

      # @param [#[]=] target
      # @param [#exported_properties] data
      # @param [Integer] depth
      def export(target, data, depth = 0)
        data.exported_properties do |key, value|
          target[key] = export_object(key, value, depth + 1)
        end
        target
      end

      # @param [Object] target
      # @param [Object] data
      # @param [Integer] depth
      def self.export(target, data, depth = 0)
        new.export(target, data, depth + 1)
      end
    end
  end
end
