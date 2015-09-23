require 'moon-prototype/load'

module Moon
  module Serializable
    # Error raised when a property could not be found
    class PropertyError < KeyError
    end

    # Properties are special attributes on an object, its default implementation,
    # is to use instance variables, to change this overwrites the
    # #property_get and #property_set methods.
    # When using Properties AND Serializable, be sure to include it BEFORE
    # Serializable, though the order shouldn't matter too much.
    module Properties
      # Properties class methods.
      module ClassMethods
        extend Moon::Prototype

        prototype_attr :property

        # Adds `name` as a property of the class.
        #
        # @param [String, Symbol] name
        # @return [Symbol] name of the property
        protected def add_property(name)
          name = name.to_sym
          properties << name
          name
        end

        # Equivalent to attr_reader {#add_property}(name)
        #
        # @param [String, Symbol] name
        # @return [Void]
        protected def property_reader(name)
          attr_reader add_property(name)
        end

        # Equivalent to attr_writer {#add_property}(name)
        # @param [String, Symbol] name
        # @return [Void]
        protected def property_writer(name)
          attr_writer add_property(name)
        end

        # Equivalent to attr_accessor {#add_property}(name)
        # @param [String, Symbol] name
        # @return [Void]
        protected def property_accessor(name)
          attr_accessor add_property(name)
        end
      end

      # Properties instance methods.
      module InstanceMethods
        # Yields each property key.
        #
        # @yieldparam [Symbol] key
        def each_property_key
          return to_enum :each_property_key unless block_given?
          self.class.each_property.each do |key|
            yield key
          end
        end

        # Checks if a property exists.
        #
        # @param [Symbol] name  property name
        # @return [Boolean] true if the property exists, false otherwise
        def has_property?(name)
          name = name.to_sym
          each_property_key { |key| return true if name == key }
          false
        end

        # Ensures that a property by `name` exists
        #
        # @param [Symbol] name  property to check for
        private def ensure_property(name)
          unless has_property?(name)
            raise PropertyError, "no such property #{name.inspect}"
          end
        end

        # Gets a property's value
        #
        # @param [Symbol] name
        # @return [Object] value
        def property_get(name)
          ensure_property name
          public_send name
        end

        # Sets a property's value
        #
        # @param [Symbol] name  property name
        # @param [Object] value
        def property_set(name, value)
          ensure_property name
          public_send "#{name}=", value
        end

        # Yields each property key and value.
        #
        # @yieldparam [Symbol] key
        # @yieldparam [Object] value
        def each_property_pair
          return to_enum :each_property_pair unless block_given?
          each_property_key do |key|
            yield key, property_get(key)
          end
        end

        alias :each_property :each_property_pair

        # Maps each property, the block is expected to ret
        #
        # @yieldparam [Symbol] key
        # @yieldparam [Object] value
        # @yieldreturn [Object] new_value
        def map_properties
          return :map_properties unless block_given?
          each_property do |key, value|
            property_set key, yield(key, value)
          end
        end

        # Returns a Hash with the properties key, value pairs
        #
        # @return [Hash<Symbol, Object>]
        def properties_to_h
          # This may be a bit slower than creating a result hash and setting
          # each key from the property.
          each_property.to_h
        end

        # (see #each_property)
        def exported_properties(&block)
          each_property(&block)
        end

        # Returns an inspect-like String with the properties key and values
        #
        # @return [String]
        def inspect_properties
          id = format('%08x', __id__)
          result = "#<#{self.class}:0x#{id}: "
          each_property_pair do |key, value|
            s = case value
            when Hash  then "#{value.empty? ? '{}' : '{...}'}(#{value.size})"
            when Array then "#{value.empty? ? '[]' : '[...]'}(#{value.size})"
            else            value.inspect
            end
            result << "#{key}=#{s} "
          end
          result[-1] = '>'
          result
        end

        # (see #inspect_properties)
        def inspect
          inspect_properties
        end
      end

      # @param [Module] mod
      def self.included(mod)
        mod.extend         ClassMethods
        mod.send :include, InstanceMethods
      end
    end
  end
end
