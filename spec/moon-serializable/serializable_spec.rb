require 'spec_helper'
require 'moon-serializable/serializable'
require 'moon-serializable/properties'

module Fixtures
  class SerializableTestObject
    include Moon::Serializable::Properties
    include Moon::Serializable

    property_accessor :x
    property_accessor :y
    property_accessor :z
    property_accessor :w

    def ==(other)
      return false unless other.is_a?(SerializableTestObject)
      each_property_pair.all? do |key, value|
        other.property_get(key) == value
      end
    end
  end
end

describe Moon::Serializable do
  let(:obj) do
    o = Fixtures::SerializableTestObject.new
    o.x = 1
    o.y = [1, 2, 3]
    o.z = { 'a' => 1, 'b' => 2, :c => 3 }
    o.w = Fixtures::SerializableTestObject.new
    o.w.x = 2
    o.w.y = 3
    o.w.z = 4
    o.w.w = 5
    o
  end

  context '#copy' do
    it 'makes a copy of the object using its serialization' do
      original = obj
      actual = obj.copy

      expect(actual).to eq(original)
    end
  end

  context '#property_set' do
    it 'sets a property given a key and value' do
      o = obj.copy
      o.property_set(:x, 2)
      expect(o.x).to eq(2)
    end
  end
end
