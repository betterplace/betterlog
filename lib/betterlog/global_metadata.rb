# To retrieve thread-global metadata that is used to enrich data that is sent
# to logging and debugging tools. In addition to holding the data
# thread-global, this will also attempt to update context of error reporting
# tools etc.

class GlobalMetadata
  include Tins::SexySingleton

  def data
    Thread.current['BP_GLOBAL_METATDATA'] || {}
  end

  def add(data_hash)
    data = data_hash | data
    Honeybadger.context(data_hash)
  end

  private

  def data=(value)
    Thread.current['BP_GLOBAL_METATDATA'] = value
  end
end
