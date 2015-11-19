require "data_path/context"
require "data_path/fork_data_collector"

module DataPath
  class Transformation
    include Enumerable
    
    def initialize(enumerable, path, options={})
      @enumerable, @path, @options = enumerable, path, options
      @context   = Context.new(@path, @options)
      @fork_data = ForkDataCollector.new(@context)
    end

    def each(&block)
      if @result
        @result.each(&block)
      else
        build_result(&block)
      end
    end

    def forks(name)
      build_result
      @path.forks(name).transform(@fork_data.fork_data(name), @options)
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

    def build_result(&block)
      @result ||= [].tap do |result| 
        @enumerable.each do |data|
          @path.call(data, @context).each do |data|
            result << data
            yield data if block_given?
          end
        end
      end
    end
  end
end