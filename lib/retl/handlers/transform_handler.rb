require_relative "step_handler"

module Retl
  class TransformHandler < StepHandler
    def call(data, context)
      dup = data.dup
      context.execute_step(step, dup)
      push_out dup
    end
  end
end