require_relative "handler"

module Retl
  class ForkHandler < Handler
    def initialize(fork)
      super()
      @fork = fork
    end

    def push_in(data, context)
      context._events.trigger(:fork_data, fork_name: @fork, data: data.dup)
      push_out data
    end
  end
end