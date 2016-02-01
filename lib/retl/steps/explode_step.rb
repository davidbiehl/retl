module Retl
  class ExplodeStep
    def initialize(callable)
      @callable = callable
    end
    
    def call(data, context)
      context.execute_step(@callable, data).each do |result|
        yield result
      end
    end
  end
end