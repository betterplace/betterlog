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
      ary = [true, false, nil, 23, 3.14]
      event = Betterlog::Log::Event.new(ary: ary << ary.dup)
      expect(event.to_json).to include(<<~end.strip)
        "ary":[true,false,null,23,3.14,[true,false,null,23,3.14]]
      end
    end
  end
end
