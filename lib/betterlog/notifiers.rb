module Betterlog
  module Notifiers

    class_attr_accessor :notifiers

    self.notifiers = Set[]

    def self.register(notifier)
      notifier.respond_to?(:notify) or raise TypeError,
        "notifier has to respond to notify(message, hash) interface"
      notifiers << notifier
      self
    end

    def self.notify(event)
      notifiers.each do |notifier|
        notifier.notify(event.notify?, event.as_hash)
      end
    end

    def self.context(data_hash)
      notifiers.each do |notifier|
        notifier.respond_to?(:context) or next
        notifier.context(data_hash)
      end
    end
  end
end
