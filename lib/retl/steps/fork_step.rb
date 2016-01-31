module Retl
  class ForkStep
    def initialize(fork)
      @fork = fork
    end

    def call(data, context)
      context._events.trigger(:fork_data, fork_name: @fork, data: data.dup)
      yield data
    end
  end
end