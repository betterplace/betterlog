require 'spec_helper'

describe Betterlog::GlobalMetadata do
  describe '.add' do
    it 'can add to context' do
      expect(Betterlog::GlobalMetadata.current).to be_empty
      Betterlog::GlobalMetadata.add(
        'foo' => 'bar',
      )
      expect(Betterlog::GlobalMetadata.current).to eq(foo: 'bar')
    end
  end

  describe '.remove' do
    it 'can remove by hash' do
      Betterlog::GlobalMetadata.add(
        'foo' => 'bar',
      )
      expect(Betterlog::GlobalMetadata.current).to eq(foo: 'bar')
      Betterlog::GlobalMetadata.remove(
        'foo' => 'bar',
      )
      expect(Betterlog::GlobalMetadata.current).to be_empty
    end

    it 'can remove by array' do
      Betterlog::GlobalMetadata.add(
        'foo' => 'bar',
      )
      expect(Betterlog::GlobalMetadata.current).to eq(foo: 'bar')
      Betterlog::GlobalMetadata.remove(%i[ foo ])
      expect(Betterlog::GlobalMetadata.current).to be_empty
    end
  end

  describe '.with_meta' do
    it 'can add to context and remove it' do
      expect(Betterlog::GlobalMetadata.current).to be_empty
      Betterlog::GlobalMetadata.with_meta(
        'foo' => 'bar',
        :bar  => 'foo',
      ) do |my_context|
        expect(Betterlog::GlobalMetadata.current).to eq(foo: 'bar', bar: 'foo')
        expect(my_context).to eq(foo: 'bar', bar: 'foo')
        expect(my_context).to be_frozen
      end
      expect(Betterlog::GlobalMetadata.current).to be_empty
    end

    it 'can add to nested context and remove it' do
      expect(Betterlog::GlobalMetadata.current).to be_empty
      Betterlog::GlobalMetadata.with_meta(
        'foo' => 'bar',
        :bar  => 'foo',
      ) do |my_context|
        expect(Betterlog::GlobalMetadata.current).to eq(foo: 'bar', bar: 'foo')
        expect(my_context).to eq(foo: 'bar', bar: 'foo')
        expect(my_context).to be_frozen
        Betterlog::GlobalMetadata.with_meta('quux' => 'quark') do |my_context|
          expect(my_context).to be_frozen
          expect(Betterlog::GlobalMetadata.current).to eq(foo: 'bar', bar: 'foo', quux: 'quark')
          expect(my_context).to eq(foo: 'bar', bar: 'foo', quux: 'quark')
        end
        expect(my_context).to eq(foo: 'bar', bar: 'foo')
      end
      expect(Betterlog::GlobalMetadata.current).to be_empty
    end

    it 'has shortcut method Betterlog.with_meta' do
      expect(Betterlog::GlobalMetadata.current).to be_empty
      Betterlog.with_meta(
        'foo' => 'bar',
        :bar  => 'foo',
      ) do
        expect(Betterlog::GlobalMetadata.current).to eq(foo: 'bar', bar: 'foo')
      end
    end
  end

  class FakeNotifierClass
    def notify(message, hash) end

    def context(data_hash) end
  end

  let :notifier do
    FakeNotifierClass.new
  end

  around do |example|
    Betterlog::Notifiers.register(notifier)
    example.run
  ensure
    Betterlog::Notifiers.notifiers.clear
    described_class.current.clear
  end

  it 'can haz empty data' do
    expect(described_class.current).to eq({})
  end

  it 'can haz some data' do
    described_class.current |= { foo: 'bar' }
    expect(described_class.current).to eq({ foo: 'bar' })
  end
end
