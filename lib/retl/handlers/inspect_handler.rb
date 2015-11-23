require_relative "step_handler"

module Retl
  class InspectHandler < StepHandler
    def call(data, context)
      context.execute_step(step, data.dup)
      push_out data
    end
  end
end