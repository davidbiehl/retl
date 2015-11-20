require "retl/context"
require "retl/fork_data_collector"

module Retl
  class Transformation
    include Enumerable
    
    def initialize(enumerable, path, options={})
      @enumerable, @path, @options = enumerable, path, options
      @context   = Context.new(@path, @options)
      @fork_data = ForkDataCollector.new(@context)
    end

    def each(&block)
      if @each
        @each.each(&block)
      else
        build_each_result(&block)
      end
    end

    def each_slice(size, &block)
      @each_slice ||= {}
      if @each_slice[size]
        @each_slice[size].each(&block)
      else
        build_each_slice_result(size, &block)
      end
    end

    def forks(name)
      build_each_result
      @path.forks(name).transform(@fork_data.take(name), @options)
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

    private

    def build_each_result(&block)
      @each ||= @enumerable.reduce([]) do |result, data|
        @path.call(data, @context).each do |data|
          yield data if block_given?
          result << data
        end
      end
    end

    def build_each_slice_result(size, &block)
      @each_slice[size] ||= @enumerable.each_slice(size).reduce([]) do |result, slice|
        transformed_slice = Transformation.new(slice, @path, @options)
        yield transformed_slice if block_given?
        result << transformed_slice
      end
    end
  end
end