class BetterlogRailtie < Rails::Railtie
  initializer "betterlog_railtie.configure_rails_initialization" do
    Rails.logger.formatter = LogEventFormatter.new
  end
end
