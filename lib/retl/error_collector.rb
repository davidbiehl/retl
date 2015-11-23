module Retl
  class ErrorCollector
    include Enumerable

    def initialize(context)
      @errors = []

      context._events.listen_to(:step_execution_error) do |args|
        @errors << args
      end
    end

    def each(&block)
      @errors.each(&block)
    end
  end
end