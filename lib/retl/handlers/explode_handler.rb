require_relative "step_handler"

module Retl
  class ExplodeHandler < StepHandler
    def call(data, context)
      context.execute_step(step, data).each do |result|
        push_out result
      end
    end
  end
end