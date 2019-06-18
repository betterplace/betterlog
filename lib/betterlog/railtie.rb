module Betterlog
  class Railtie < Rails::Railtie
    initializer "betterlog_railtie.configure_rails_initialization" do
      Rails.logger = Betterlog::Logger.new(Redis.new) # TODO
      Rails.logger.formatter = Betterlog::LogEventFormatter.new
    end
  end
end
