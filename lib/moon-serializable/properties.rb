require 'moon-prototype/load'

module Moon
  module Serializable
    # Properties are special attributes on an object, its default implementation,
    # is to use instance variables, to change this overwrites the
    # #property_get and #property_set methods.
    # When using Properties AND Serializable, be sure to include it BEFORE
    # Serializable, though the order shouldn't matter too much.
    module Properties
      module ClassMethods
        extend Moon::Prototype

        prototype_attr :property

        # Adds +name+ as a property of the class.
        #
        # @param [String, Symbol] name
        # @return [Symbol] name of the property
        private def add_property(name)
          name = name.to_sym
          properties << name
          name
        end

        # Equivalent to attr_reader property(name)
        # @param [String, Symbol] name
        # @return [Void]
        private def property_reader(name)
          attr_reader add_property(name)
        end

        # Equivalent to attr_writer property(name)
        # @param [String, Symbol] name
        # @return [Void]
        private def property_writer(name)
          attr_writer add_property(name)
        end

        # Equivalent to attr_accessor property(name)
        # @param [String, Symbol] name
        # @return [Void]
        private def property_accessor(name)
          attr_accessor add_property(name)
        end
      end

      module InstanceMethods
        # @param [Symbol] key
        def property_get(key)
          public_send key
        end

        # @param [Symbol] key
        # @param [Object] value
        def property_set(key, value)
          public_send "#{key}=", value
        end

        # @yieldparam [Symbol] key
        def each_property_key
          return to_enum :each_property_key unless block_given?
          self.class.each_property.each do |key|
            yield key
          end
        end

        # @yieldparam [Symbol] key
        # @yieldparam [Object] value
        def each_property_pair
          return to_enum :each_property_pair unless block_given?
          each_property_key do |key|
            yield key, property_get(key)
          end
        end

        alias :each_property :each_property_pair

        # @yieldparam [Symbol] key
        # @yieldparam [Object] value
        # @yieldreturn [Object] new_value
        def map_properties
          each_property do |key, value|
            property_set key, yield(key, value)
          end
        end

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

        # @return [String]
        def inspect_properties
          id = format('%08x', __id__)
          result = "<#{self.class}#0x#{id}: "
          each_property_pair do |key, value|
            s = case value
            when Hash
              "#{value.empty? ? '{}' : '{...}'}[#{value.size}]"
            when Array
              "#{value.empty? ? '[]' : '[...]'}[#{value.size}]"
            else
              value.inspect
            end
            result << "#{key}=#{s} "
          end
          result[-1] = '>'
          result
        end

        # @return [String]
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
