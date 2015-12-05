require "retl/context"
require "retl/fork_data_collector"
require "retl/errors/step_execution_error"
require_relative "default_execution"
require_relative "threaded_execution"

module Retl
  class Transformation
    include Enumerable

    attr_writer :execution_strategy

    def initialize(enumerable, path, options={})
      @enumerable, @path, @options = enumerable, path, options
      @context   = Context.new(@path, @options)
      @fork_data = ForkDataCollector.new(@context)
      @forks     = {}
      @errors    = []
      self.execution_strategy = DefaultExecution
    end

    def execution_strategy=(strategy)
      @execution_strategy = strategy.new(@enumerable, @path, @context, @errors)
    end

    def each(&block)
      @execution_strategy.each(&block)
    end

    def each_slice(size, &block)
      @enumerable.each_slice(size).map do |slice|
        Transformation.new(slice, @path, @options).tap do |transformed_slice|
          yield transformed_slice if block_given?
        end
      end
    end

    def forks(name)
      unless @forks[name]
        each unless @execution_strategy.executed?
        @forks[name] = @path.forks(name).transform(@fork_data.take(name), @options)
        @forks[name].execution_strategy = @execution_strategy.class
      end

      @forks[name]
    end

    def load_into(*destinations)
      @execution_strategy.load_into(*destinations)
    end

    def errors
      @errors.each
    end
  end
end