module Retl
  class StepHandler
    attr_accessor :description

    def initialize(step, description = "unknown")
      @output      = []
      @description = description
      @step        = step
    end

    def output
      @output.slice!(0, @output.count)
    end

    def push_in(data, context)
      @step.call(data, context) do |result|
        push_out result
      end
    end

    private

    def push_out(data)
      @output.push data
    end
  end
end
