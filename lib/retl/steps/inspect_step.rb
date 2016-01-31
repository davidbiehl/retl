module Retl
  class InspectStep
    def initialize(callable)
      @callable = callable
    end

    def call(data, context)
      context.execute_step(@callable, data.dup)
      yield data
    end
  end
end