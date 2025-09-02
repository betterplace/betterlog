module Betterlog
  # Integrates Betterlog with Rails application initialization.
  #
  # This Railtie is responsible for configuring Rails to use Betterlog's legacy event formatter
  # as the default logger formatter. It ensures that log messages are properly structured
  # and enriched with metadata when used within a Rails application context.
  #
  # @see Betterlog::Log::LegacyEventFormatter
  # @see Rails::Railtie
  class Railtie < Rails::Railtie
    initializer "betterlog_railtie.configure_rails_initialization" do
      require 'betterlog/log/legacy_event_formatter'
      Rails.logger.formatter = Betterlog::Log::LegacyEventFormatter.new
    end
  end
end
