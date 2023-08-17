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
      event.notify? or return
      notifiers.each do |notifier|
        context(event.as_json)
        notifier.notify(event[:message], event.as_json)
      end
    end

    def self.context(data)
      notifiers.each do |notifier|
        notifier.respond_to?(:context) or next
        notifier.context(data)
      end
    end
  end
end
