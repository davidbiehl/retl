require_relative "step_handler"

module Retl
  class TransformHandler < StepHandler
    def push_in(data, context)
      context.execute_step(step, data)
      push_out data
    end
  end
end