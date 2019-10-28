require 'spec_helper'

describe Betterlog::Log::Event do
  describe '#to_json' do
    it 'can deal with circular arrays' do
      circular_array = [].tap { |arr| arr << arr }
      event = Betterlog::Log::Event.new(array: circular_array)
      expect(event.to_json).to include('"array":[["circular"]]')
    end

    # TODO: this currently crashes in tins' #symbolize_keys_recursive
    xit 'can deal with circular hashes' do
      circular_hash = {}.tap { |hash| hash['foo'] = hash }
      event = Betterlog::Log::Event.new(hash: circular_hash)
      expect(event.to_json).to include('"hash":{"foo":"circular"}')
    end

    # regression test
    it 'does not replace repeated scalar objects with "circular"' do
      event = Betterlog::Log::Event.new(array: [true, true])
      expect(event.to_json).to include('"array":[true,true],')
    end
  end
end
