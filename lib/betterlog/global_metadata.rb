# To retrieve thread-global metadata that is used to enrich data that is sent
# to logging and debugging tools. In addition to holding the data
# thread-global, this will also attempt to update context of error reporting
# tools etc.

module Betterlog
  class GlobalMetadata
    include Tins::SexySingleton

    thread_local(:data) { {} }

    def add(data_hash)
      data_hash = data_hash.symbolize_keys_recursive
      data = data_hash | data
      Notifiers.context(data_hash)
      self
    end
  end
end
