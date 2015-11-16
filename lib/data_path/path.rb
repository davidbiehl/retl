require "data_path/path_builder"
require "data_path/realization"

module DataPath
  class Path
    attr_reader :steps, :source

    def initialize(parent=nil, &block)
      @steps   = []
      @outlets = {}
      
      add_step parent.dup if parent
      build(&block)       if block
    end

    def build(&block)
      PathBuilder.new(self, &block)
    end

    def initialize_copy(source)
      @steps   = source.steps.dup
      @outlets = {}
    end

    def add_step(step)
      @steps << step
    end

    def outlets
      @outlets
    end

    def call(data)
      @steps.reduce(data) do |result, step|
        step.call(result.dup)
      end
    end

    def add_outlet(name, outlet)
      @outlets[name] = outlet 
    end

    def realize(enumerable)
      Realization.new(enumerable, self)
    end
  end
end