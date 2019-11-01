require 'spec_helper'

describe Betterlog::Log::Severity do
  it 'has all constants' do
    expect(described_class.all.map(&:to_s).sort).to\
      eq %w[ WARN ERROR FATAL UNKNOWN DEBUG INFO ].sort
  end

  it 'resolves unknown severities to UNKNOWN' do
    expect(described_class.new('NIX')).to eq(described_class.new(:UNKNOWN))
  end

  context 'severity instance' do
    subject do
      described_class.new('error')
    end

    it 'can be converted to integer' do
      expect(subject.to_i).to eq 3
    end

    it 'can be converted to symbol' do
      expect(subject.to_sym).to eq :error
    end

    it 'can be converted to string' do
      expect(subject.to_s).to eq 'ERROR'
    end

    it 'can be converted to json' do
      expect(subject.to_json).to eq '"ERROR"'
    end

    it 'can be converted via as_json' do
      expect(subject.as_json).to eq 'ERROR'
    end

    it 'can be compared by level' do
      expect(subject).to be < described_class.new(:FATAL)
    end

    it 'can be compared by level via symbol' do
      expect(subject).to be < :FATAL
    end

    it 'implements hash depending on name symbol' do
      expect(subject.hash).to eq :error.hash
    end
  end
end

