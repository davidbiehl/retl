require "data_path/step_handler"

module DataPath
  class InspectHandler < StepHandler
    def push_in(data, context)
      context.execute_step(step, data.dup)
      push_out data
    end
  end
end