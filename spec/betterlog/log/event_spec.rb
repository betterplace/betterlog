require 'spec_helper'

describe Betterlog::Log::Event do
  describe '#as_hash' do
    it 'dups hash before returning it' do
      event = described_class.new
      expect(event.as_hash).not_to equal event.instance_variable_get(:@data)
    end
  end

  describe '#to_json' do
    it 'can deal with circular arrays' do
      circular_array = [].tap { |arr| arr << arr }
      event = described_class.new(array: circular_array)
      expect(event.to_json).to include('"array":["circular"]')
    end

    it 'can deal with circular hashes' do
      circular_hash = {}.tap { |hash| hash['foo'] = hash }
      event = described_class.new(hash: circular_hash)
      expect(event.to_json).to include('"hash":{"foo":"circular"}')
    end

    it 'does not replace repeated scalar objects with "circular"' do
      ary = [true, false, nil, 23, 3.14]
      event = described_class.new(ary: ary << ary.dup)
      expect(event.to_json).to include(<<~end.strip)
        "ary":[true,false,null,23,3.14,[true,false,null,23,3.14]]
      end
    end
  end
end
