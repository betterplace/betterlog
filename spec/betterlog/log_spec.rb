require 'spec_helper'

describe Betterlog::Log do
  around do |example|
    Time.dummy '2011-11-11 11:11:11+01:00' do
      example.run
    end
  end

  let :instance do
    described_class.instance
  end

  let :event do
    Log::Event.ify('hello')
  end

  describe 'Log::Event.ify' do
    it 'can eventify a string' do
      expect(event).to be_a Log::Event
    end

    it 'can eventify a hash' do
      event = Log::Event.ify({ message: 'hallo' })
      expect(event).to be_a Log::Event
    end
  end

  describe 'Log::Event.to_json' do
    it 'can be called' do
      expect(event.to_json).to be_present
    end

    it 'can handle invalid UTF-8 characters' do
      event = Log::Event.ify("foo\xCEbar")
      expect(event.to_json).to eq(JSON(severity: "DEBUG", message: 'foobar'))
    end
  end

  describe '.parse' do
    it 'can parse an event as a JSON document' do
      expect(Log::Event.parse(event.to_json)).to eq event
    end
  end

  describe "#[severity]" do
    it 'logs freetext, unstructured messages to Rails.logger on used log level' do
      for severity in %i[ debug error fatal info warn ] do
        log_event = Log::Event.new(
          message: 'some freetext message',
          severity: severity
        )
        expect(instance).to receive(:emit).with(log_event)
        Log.instance.send(severity, 'some freetext message')
      end
    end
  end

  describe '#output' do
    it 'logs freetext, unstructured messages to Rails.logger on given log level' do
      log_event = Log::Event.new(
        message: 'some freetext message',
        severity: :warn
      )
      expect(instance).to receive(:emit).with(log_event)
      Log.output('some freetext message', severity: :warn)
    end
  end

  describe '#info with internal logging error' do
    it 'should not crash ever, just log the problem to Rails.logger' do
      expect_any_instance_of(instance.logger.class).to receive(:fatal)
      expect(Log.info(BasicObject.new)).to eq Log.instance
    end
  end

  describe '#notify?' do
    let :notifier do
      Class.new do
        def notify(message, hash) end

        def context(data) end
      end.new
    end

    around do |example|
      Betterlog::Notifiers.register(notifier)
      example.run
    ensure
      Betterlog::Notifiers.notifiers.clear
    end

    before do
      expect_any_instance_of(::Logger).to receive(:send).with(:info, any_args)
    end

    it 'can send explicit notifications' do
      expect(notifier).to receive(:notify).with(
        'test',
        hash_including(message: 'test')
      )
      Log.info('test', notify: true)
    end

    it 'can send explicit notifications with additional hash values' do
      expect(notifier).to receive(:notify).with(
        'test',
        hash_including(meta: { foo: 'bar' }),
      )
      Log.info({ message: 'test', meta: { foo: 'bar' } }, notify: true)
    end

    it 'can send notifications with additional hash values for context' do
      expect(notifier).to receive(:notify).with(
        'test',
        hash_including(meta: { foo: 'bar' }),
      )
      Betterlog.with_meta(foo: 'bar') do
        Log.info('test', notify: true)
      end
    end

    it 'can send explicit notifications for exceptions' do
      e = raise "foo" rescue $!
      expect(notifier).to receive(:notify).with(
        'RuntimeError: foo',
        hash_including(
          error_class: 'RuntimeError'
        )
      )
      Log.info(e, notify: true)
    end
  end

  describe '#output exceptions' do
    it 'logs ruby standard errors' do
      exception = ArgumentError.new('unknown keyword: xyz')
      exception.set_backtrace(Thread.current.backtrace)
      expected_event = Log::Event.new(
        error_class: exception.class.name,
        message:     "#{exception.class.name}: #{exception.message}",
        backtrace:   exception.backtrace,
      )
      expect(instance).to receive(:emit).with(expected_event)
      Log.output(exception)
    end

    it 'logs a ruby exception with additional data' do
      exception = ArgumentError.new('unknown keyword: xyz')
      exception.set_backtrace(Thread.current.backtrace)
      expected_event = Log::Event.new(
        foo:         'bar',
        error_class: exception.class.name,
        message:     "#{exception.class.name}: #{exception.message}",
        backtrace:   exception.backtrace,
        severity:    :error,
      )
      expect(instance).to receive(:emit).with(expected_event)
      Log.error(exception, foo: 'bar')
    end
  end
end
