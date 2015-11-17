require "data_path/step_handler"

module DataPath
  class TransformHandler < StepHandler
    def push_in(data, context)
      context.execute_step(step, data)
      push_out data
    end
  end
end