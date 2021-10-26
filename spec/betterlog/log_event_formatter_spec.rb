require 'spec_helper'
module ActiveSupport
  class Logger
    class Formatter
      def call(severity, timestamp, program, message)
        message
      end
    end
  end
  module TaggedLogging
    module Formatter
    end
  end
end
require 'betterlog/log_event_formatter'

describe Betterlog::LogEventFormatter do
  let :red do
    Term::ANSIColor.red { "red" }
  end

  it 'strips blank messages' do
    message = described_class.new.(:info, Time.now, 'foo', '    ')
    expect(message).to eq ?\n
  end

  it 'uncolors colored message strings' do
    json = described_class.new.(:info, Time.now, 'foo', red)
    data = JSON.parse(json)
    expect(data['message']).to eq 'red'
  end

  it 'deconstructs backtraces' do
    msg = <<~end
    foo.rb:6:in `bar': hi (RuntimeError)
        from foo.rb:2:in `foo'
        from foo.rb:9:in `<main>'
    end
    json = described_class.new.(:info, Time.now, 'foo', msg)
    data = JSON.parse(json)
    expect(data['message']).to eq "foo.rb:6:in `bar': hi (RuntimeError)\n"
    expect(data['backtrace']).to eq [
      "foo.rb:6:in `bar': hi (RuntimeError)",
      "    from foo.rb:2:in `foo'",
      "    from foo.rb:9:in `<main>'"
    ]
  end
end
