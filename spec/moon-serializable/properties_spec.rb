require 'spec_helper'
require 'moon-serializable/properties'

module Fixtures
  class PropertiesTestObject
    include Moon::Serializable::Properties

    # these are only used to touch the code routes, they're just wrappers
    # round the regular attr_reader, attr_writer and attr_accessor,
    # they simply call add_property with the provided value as well
    property_reader :a   # same as attr_reader add_property(:a)
    property_writer :b   # same as attr_writer add_property(:b)
    property_accessor :c # same as attr_accessor add_property(:c)

    attr_writer :a
    attr_reader :b
  end
end

describe Moon::Serializable::Properties do
  context '#exported_properties' do
    it 'yields each property key, value pair' do
      obj = Fixtures::PropertiesTestObject.new
      expect { |b| obj.exported_properties(&b) }.to yield_successive_args([:a, nil], [:b, nil], [:c, nil])
    end
  end

  context '#map_properties' do
    it 'replaces all properties with result from the block' do
      obj = Fixtures::PropertiesTestObject.new
      obj.map_properties do |key, value|
        if key == :a
          1
        elsif key == :b
          2
        elsif key == :c
          3
        end
      end
      expect { |b| obj.each_property(&b) }.to yield_successive_args([:a, 1], [:b, 2], [:c, 3])
    end
  end

  context '#properties_to_h' do
    it 'returns a Hash of all property key, value pairs' do
      obj = Fixtures::PropertiesTestObject.new
      obj.a = 1
      obj.b = 2
      obj.c = 3
      actual = obj.properties_to_h
      expect(actual).to eq(a: 1, b: 2, c: 3)
    end
  end

  context '#inspect' do
    # TODO. give this a better description
    it 'returns a inpsect like String' do
      obj = Fixtures::PropertiesTestObject.new
      obj.a = [1]
      obj.b = {}
      expect(obj.inspect).to match(/\<Fixtures::PropertiesTestObject#0x(\h+): a=\[\.\.\.\]\[1\] b=\{\}\[0\] c=nil>/)
    end
  end
end
