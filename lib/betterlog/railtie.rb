module Betterlog
  class Railtie < Rails::Railtie
    initializer "betterlog_railtie.configure_rails_initialization" do
      require 'betterlog/log_event_formatter'
      Rails.logger.formatter = Betterlog::LogEventFormatter.new
    end
  end
end
