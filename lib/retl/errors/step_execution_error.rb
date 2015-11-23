module Retl
  class StepExecutionError < StandardError
    attr_reader :input_data, :current_data, :step, :cause

    def initialize(input_data: nil, current_data: nil, step: nil, cause: $!)
      @input_data, @current_data = input_data, current_data
      @step, @cause = step, cause

      super("#{cause} (at step: #{step_description}))")
      set_backtrace(cause.backtrace)
    end

    def step_description
      @step.description
    end
  end
end