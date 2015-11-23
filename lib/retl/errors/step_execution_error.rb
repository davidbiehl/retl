module Retl
  class StepExecutionError < StandardError
    attr_reader :input_data, :current_data, :step, :cause

    def initialize(input_data: nil, current_data: nil, step: nil, cause: $!)
      @input_data, @current_data = input_data, current_data
      @step, @cause = step, cause

      super(cause)
      set_backtrace(cause.backtrace)
    end
  end
end