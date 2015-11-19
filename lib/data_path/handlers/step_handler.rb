require_relative "handler"

module DataPath
  class StepHandler < Handler
    attr_reader :step

    def initialize(step)
      super()
      @step = step
    end

    def push_in(data, context)
      push_out context.execute_step(step, data)
    end
  end
end