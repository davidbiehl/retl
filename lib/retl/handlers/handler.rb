module Retl
  class Handler
    def initialize
      @output = []
    end

    def output
      @output.slice!(0, @output.count)
    end

    def push_in(data, context)
      call(data, context)
    rescue Exception => e
      if Retl.configuration.raise_errors
        raise e
      else
        context._events.trigger(:step_execution_error, {step: self, data: data, error: e})
      end
    end

    def call(data, context)
      raise NotImplementedError, "Handlers much implement the #push_in(data, context) method"
    end

    private

    def push_out(data)
      @output.push data
    end
  end
end