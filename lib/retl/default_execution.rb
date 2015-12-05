module Retl
  class DefaultExecution
    def initialize(enumerable, path, context, errors)
      @enumerable, @path, @context, @errors = enumerable, path, context, errors
      @executed = false
    end

    def each(&block)
      @executed = true
      @enumerable.each do |data|
        execute(data, &block)
      end
    end

    def execute(input)
      @path.call(input, @context).each do |data|
        yield data if block_given?
      end
    rescue StepExecutionError => e
      if Retl.configuration.raise_errors
        raise e
      else
        @errors << e
      end
    end

    def load_into(*destinations)
      destinations = Array(destinations)

      each do |data|
        destinations.each do |destination|
          destination << data
        end
      end

      destinations.each do |destination|
        destination.close if destination.respond_to?(:close)
      end
    end

    def executed?
      @executed
    end
  end
end