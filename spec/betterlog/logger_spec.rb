require 'spec_helper'

describe Betterlog::Logger do
  let :logger do
    described_class.new(Redis.new)
  end

  describe '#<<' do
    it 'writes to redis' do
      expect(logger.instance_variable_get(:@redis)).to receive(:append).
        with('Betterlog::Logger', 'foo')
      logger << 'foo'
    end
  end

  describe '#add' do
    it 'writes to redis' do
      expect(logger.instance_variable_get(:@redis)).to receive(:append).
        with('Betterlog::Logger', /INFO -- : foo/)
      logger.info 'foo'
    end
  end

  describe '#each_chunk' do
    it 'iterates over chunks of data' do
      logger.clear
      logger << "foo" * 23
      expect(logger.each_chunk(chunk_size: 10).to_a).to eq %w[
        foofoofoof
        oofoofoofo
        ofoofoofoo
        foofoofoof
        oofoofoofo
        ofoofoofoo
        foofoofoo
      ]
    end

    it 'works if no data is there' do
      logger.clear
      expect(logger.each_chunk(chunk_size: 1).to_a).to eq []
    end

    it 'iterates if chunk_size is 1 and 23' do
      logger.clear
      logger << ?. * 23
      expect(logger.each_chunk(chunk_size: 1).to_a).to eq [ ?. ] * 23
    end

    it 'iterates if chunk_size is 1 and 22' do
      logger.clear
      logger << ?. * 22
      expect(logger.each_chunk(chunk_size: 1).to_a).to eq [ ?. ] * 22
    end
  end

  describe '#each' do
    it 'iterates over log lines' do
      logger.clear
      logger << "foo\n"
      logger << "bar\n"
      expect(logger.to_a).to eq [ "foo\n", "bar\n" ]
    end
  end
end