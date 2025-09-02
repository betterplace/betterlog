# To retrieve thread-global metadata that is used to enrich data that is sent
# to logging and debugging tools. In addition to holding the data
# thread-global, this will also attempt to update current of error reporting
# tools etc.

module Betterlog

  # Thread-local storage for global metadata used to enrich log events.
  #
  # This class provides a thread-safe mechanism to store and manage metadata
  # that should be included with log events. It ensures that metadata is
  # scoped to the current thread and can be easily added, removed, or
  # temporarily applied within a block context.
  #
  # @see Betterlog::Log::Event
  # @see Betterlog.with_meta
  class GlobalMetadata
    include Tins::SexySingleton

    thread_local(:current) { {} }

    # Adds metadata to the current thread-local storage.
    #
    # This method takes a hash of data and merges it with the existing metadata
    # in the current thread's storage. The provided data is symbolized and then
    # combined with the current metadata using a union operation, ensuring that
    # new keys overwrite existing ones with the same name.
    #
    # @param data [ Hash ] A hash containing the metadata to be added
    # @return [ Betterlog::GlobalMetadata ] Returns the GlobalMetadata instance itself
    def add(data)
      data = data.symbolize_keys_recursive
      self.current = data | current
      self
    end

    # Removes metadata keys from the current thread-local storage.
    #
    # This method takes a hash or array of keys and deletes the corresponding
    # entries from the global metadata stored in the current thread. It ensures
    # that only the specified keys are removed, leaving other metadata intact.
    #
    # @param data [ Hash, Array ] A hash containing keys to remove or an array
    # of key symbols
    # @return [ void ] Returns nil after removing the specified keys
    def remove(data)
      keys = data.ask_and_send_or_self(:keys).map(&:to_sym)
      keys.each { current.delete(_1) }
    end

    # Temporarily adds metadata to the current thread-local storage for the
    # duration of a block execution.
    #
    # This method allows for the temporary addition of metadata to the global
    # metadata store within the context of a block. The metadata is
    # automatically removed after the block completes, ensuring that the
    # metadata changes do not persist beyond the intended scope.
    #
    # @param data [ Hash ] A hash containing the metadata key-value pairs to be added
    # @yield [ data ] Executes the provided block with the metadata in place
    # @return [ void ] Returns nil after the block has been executed and metadata removed
    def with_meta(data = {}, &block)
      add data
      block.call
    ensure
      remove data
    end
  end

  # Provides a convenient way to temporarily add metadata to the global
  # metadata store within the scope of a block.
  #
  # This method serves as a shortcut to Betterlog::GlobalMetadata.with_meta,
  # allowing for easy temporary addition of metadata that is automatically
  # removed after the block execution completes.
  #
  # @param data [ Hash ] A hash containing the metadata key-value pairs to be added
  # @yield [ data ] Executes the provided block with the metadata in place
  # @return [ void ] Returns nil after the block has been executed and metadata removed
  def self.with_meta(data = {}, &block)
    Betterlog::GlobalMetadata.with_meta(data, &block)
  end
end
