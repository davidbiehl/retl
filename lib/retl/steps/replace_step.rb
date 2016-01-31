module Retl
  class ReplaceStep
    def initialize(callable)
      @callable = callable
    end

    def call(data, context)
      yield context.execute_step(@callable, data)
    end
  end
end