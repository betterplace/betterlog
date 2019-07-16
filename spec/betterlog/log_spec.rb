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
      event = Log::Event.ify(message: 'hallo')
      expect(event).to be_a Log::Event
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
      expect_any_instance_of(instance.logger.class).to receive(:fatal).and_call_original
      expect(Log.info(BasicObject.new)).to eq Log.instance
    end
  end

  describe '#notify?' do
    let :notifier do
      Class.new do
        def notify(message, hash) end
      end.new
    end

    around do |example|
      Betterlog::Notifiers.register(notifier)
      example.run
    ensure
      Betterlog::Notifiers.notifiers.clear
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
        hash_including(message: 'test', foo: 'bar')
      )
      Log.info({ message: 'test', foo: 'bar' }, notify: true)
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

  describe '#measure' do
    after do
      Time.dummy = nil
    end

    it 'can be sent after measuring times' do
      expected_event = Log::Event.new(
        message: 'a metric foo of type seconds',
        metric:    'foo',
        type:      'seconds',
        value:     10.0,
        timestamp: "2011-11-11T10:11:21.000Z"
      )
      expect(instance).to receive(:emit).with(expected_event)
      Log.measure(metric: 'foo') do
        Time.dummy = Time.now + 10
      end
    end

    class MyEx < StandardError
      def backtrace
        %w[ backtrace ]
      end
    end

    it 'adds exception information if block raises' do
      expected_event = Log::Event.new(
        metric:      'foo',
        type:        'seconds',
        value:       3.0,
        timestamp:   "2011-11-11T10:11:14.000Z",
        message:     '"MyEx: we were fucked" while measuring metric foo',
        error_class: 'MyEx',
        backtrace:   %w[ backtrace ]
      )
      expect(instance).to receive(:emit).with(expected_event)
      raised = false
      begin
        Log.measure(metric: 'foo') do
          Time.dummy = Time.now + 3
          raise MyEx, "we were fucked"
          Time.dummy = Time.now + 7
        end
      rescue MyEx
        raised = true
      end
      expect(raised).to eq true
    end
  end

  describe '#metric' do
    it 'logs metrics with a specific structure on debug log level' do
      expected_event = Log::Event.new(
        message: 'a metric controller.action of type ms',
        metric: 'controller.action',
        type: 'ms',
        value: 0.123,
      )
      expect(instance).to receive(:emit).with(expected_event)
      Log.metric(metric: 'controller.action', type: 'ms', value: 0.123)
    end

    it 'logs metrics on a given log level' do
      expected_event = Log::Event.new(
        message: 'a metric controller.action of type ms',
        metric: 'controller.action',
        type:   'ms',
        value:  0.123,
        severity: :info,
      )
      expect(instance).to receive(:emit).with(expected_event)
      Log.metric(severity: :info, metric: 'controller.action', type: 'ms', value: 0.123)
    end

    it 'logs metrics with additional data' do
      expected_event = Log::Event.new(
        message: 'a metric controller.action of type ms',
        foo: 'bar',
        metric: 'controller.action',
        type: 'ms',
        value: 0.123,
      )
      expect(instance).to receive(:emit).with(expected_event)
      Log.metric(metric: 'controller.action', type: 'ms', value: 0.123, foo: 'bar')
    end
  end
end
