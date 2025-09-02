module Betterlog
  # Module for managing and coordinating log event notifiers.
  #
  # This module provides a centralized mechanism for registering and notifying
  # objects when specific log events occur. It maintains a collection of
  # notifier instances that can respond to log events, allowing for flexible
  # integration with external monitoring, alerting, or logging systems.
  # Notifiers are invoked when log events explicitly request notification,
  # enabling decoupled communication between the logging system and downstream
  # services.
  #
  # @see Betterlog::Log#emit
  # @see Betterlog::Log::Event#notify?
  module Notifiers

    class_attr_accessor :notifiers

    self.notifiers = Set[]

    # Registers a notifier object with the Notifiers module.
    #
    # This method adds a notifier to the collection of registered notifiers,
    # ensuring that it responds to the required notify interface. The notifier
    # will subsequently be invoked when log events with notification requests
    # are emitted.
    #
    # @param notifier [ Object ] the notifier object to be registered
    # @return [ Class ] Returns the Notifiers class itself
    def self.register(notifier)
      notifier.respond_to?(:notify) or raise TypeError,
        "notifier has to respond to notify(message, hash) interface"
      notifiers << notifier
      self
    end

    # Notifies registered notifiers with the event data.
    #
    # This method checks if the provided event has notification enabled,
    # and if so, iterates through all registered notifiers to send them
    # the event's message and metadata. It also updates the context for
    # each notifier before sending the notification.
    #
    # @param event [Betterlog::Log::Event] the log event to be notified about
    def self.notify(event)
      event.notify? or return
      notifiers.each do |notifier|
        context(event.as_json)
        notifier.notify(event[:message], event.as_json)
      end
    end

    # Sets the context for all registered notifiers with the provided data.
    #
    # This method iterates through all registered notifiers and invokes their
    # context method if they respond to it, passing the given data hash to
    # allow notifiers to update their internal state or configuration based
    # on the provided context information.
    #
    # @param data [ Hash ] A hash containing the context data to be passed
    #   to each notifier that supports the context interface
    def self.context(data)
      notifiers.each do |notifier|
        notifier.respond_to?(:context) or next
        notifier.context(data)
      end
    end
  end
end
