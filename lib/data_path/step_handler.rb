module DataPath
  class StepHandler
    attr_reader :step

    def initialize(step)
      @step   = step
      @output = []
    end

    def push_in(data, context)
      push_out context.execute_step(step, data)
    end

    def output
      @output.slice!(0, @output.count)
    end

    private

    def push_out(data)
      @output.push data
    end
  end
end