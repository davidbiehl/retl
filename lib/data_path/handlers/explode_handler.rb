require_relative "step_handler"

module DataPath
  class ExplodeHandler < StepHandler
    def push_in(data, context)
      context.execute_step(step, data).each do |result|
        push_out result
      end
    end
  end
end