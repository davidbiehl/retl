require_relative "step_handler"

module Retl
  class FilterHandler < StepHandler
    def call(data, context)
      keep = context.execute_step(step, data)
      push_out data if keep
    end
  end
end