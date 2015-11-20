module Retl
  class ForkDataCollector
    def initialize(context)
      @fork_data = {}

      context._events.listen_to(:fork_data) do |args|
        fork_name = args[:fork_name]
        @fork_data[fork_name] ||= []
        @fork_data[fork_name] << args[:data]
      end
    end

    def take(name)
      @fork_data.delete(name)
    end
  end
end