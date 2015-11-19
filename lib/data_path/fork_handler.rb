require "data_path/step_handler"

module DataPath
  class ForkHandler < StepHandler
    def initialize(fork)
      super(nil)
      @fork = fork
    end

    def push_in(data, context)
      context._events.trigger(:fork_data, fork_name: @fork, data: data.dup)
      push_out data
    end
  end
end