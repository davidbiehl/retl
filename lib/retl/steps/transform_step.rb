module Retl
  class TransformStep 
    def initialize(callable)
      @callable = callable
    end

    def call(data, context)
      dup = data.dup
      context.execute_step(@callable, dup)
      yield dup
    end
  end
end