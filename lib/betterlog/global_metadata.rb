# To retrieve thread-global metadata that is used to enrich data that is sent
# to logging and debugging tools. In addition to holding the data
# thread-global, this will also attempt to update current of error reporting
# tools etc.

module Betterlog
  class GlobalMetadata
    include Tins::SexySingleton

    thread_local(:current) { {} }

    def add(data)
      data = data.symbolize_keys_recursive
      self.current = data | current
      self
    end

    def remove(data)
      keys = data.ask_and_send_or_self(:keys).map(&:to_sym)
      keys.each { current.delete(_1) }
    end

    def with_meta(data = {}, &block)
      add data
      block.call
    ensure
      remove data
    end
  end

  def self.with_meta(data = {}, &block)
    Betterlog::GlobalMetadata.with_meta(data, &block)
  end
end
