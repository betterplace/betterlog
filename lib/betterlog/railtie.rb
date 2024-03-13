module Betterlog
  class Railtie < Rails::Railtie
    initializer "betterlog_railtie.configure_rails_initialization" do
      require 'betterlog/log/legacy_event_formatter'
      Rails.logger.formatter = Betterlog::Log::LegacyEventFormatter.new
    end
  end
end
