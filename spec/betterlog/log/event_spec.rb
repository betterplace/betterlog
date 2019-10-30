require 'spec_helper'

describe Betterlog::Log::Event do
  describe '#to_json' do
    it 'can deal with circular arrays' do
      circular_array = [].tap { |arr| arr << arr }
      event = Betterlog::Log::Event.new(array: circular_array)
      expect(event.to_json).to include('"array":["circular"]')
    end

    it 'can deal with circular hashes' do
      circular_hash = {}.tap { |hash| hash['foo'] = hash }
      event = Betterlog::Log::Event.new(hash: circular_hash)
      expect(event.to_json).to include('"hash":{"foo":"circular"}')
    end

    it 'does not replace repeated scalar objects with "circular"' do
      event = Betterlog::Log::Event.new(array: [true, false, nil, 23, 3.14])
      expect(event.to_json).to include('"array":[true,false,null,23,3.14],')
    end
  end
end
