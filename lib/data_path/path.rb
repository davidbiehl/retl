require "data_path/path_builder"

module DataPath
  class Path
    include Enumerable

    attr_reader :steps, :source

    def initialize(source, &block)
      @source = source
      @steps = []
      @outlets = {}
      
      if block
        build(&block)
      end
    end

    def build(&block)
      PathBuilder.new(self, &block)
    end

    def add_step(step)
      @steps << step
    end

    def outlets
      @outlets
    end

    def add_outlet(name, outlet)
      @outlets[name] = outlet 
    end

    def each
      @source.each do |data|
        catch(:skip) do 
          @steps.each do |step|
            data = step.call(data)
          end
          yield(data)
        end
      end
    end
  end
end