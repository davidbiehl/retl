require_relative "handler"

module Retl
  class StepHandler < Handler
    attr_reader :step

    def initialize(step)
      super()
      @step = step
    end

    def call(data, context)
      push_out context.execute_step(step, data)
    end
  end
end