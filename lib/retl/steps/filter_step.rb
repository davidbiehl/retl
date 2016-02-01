module Retl
  class FilterStep
    def initialize(callable)
      @callable = callable
    end

    def call(data, context)
      keep = context.execute_step(@callable, data)
      yield data if keep
    end
  end
end