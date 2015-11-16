require "data_path/filter_step"
require "data_path/transform_step"
require "data_path/inspect_step"

module DataPath
  class PathBuilder
    def initialize(path, &block)
      @path = path
      instance_eval(&block)
    end

    def step(step=nil, &block)
      step ||= block
      @path.add_step step
    end

    def transform(action=nil, &block)
      action ||= block
      step(TransformStep.new(action))
    end

    def filter(predicate=nil, &block)
      predicate ||= block
      step(FilterStep.new(predicate))
    end
    alias_method :select, :filter

    def outlet(name, &block)
      outlet = Path.new(@path, &block)
      @path.add_outlet(name, outlet)
    end

    def inspect(action=nil, &block)
      action ||= block
      step(InspectStep.new(action))
    end

    def reject(predicate=nil, &block)
      predicate ||= block
      filter { |data, context| !context.execute_step(predicate, data) }
    end

    def calculate(key, action=nil, &block)
      action ||= block
      transform { |data, context| data[key] = context.execute_step(action, data) }
    end
    alias_method :calc, :calculate

    def depends_on(name, source=nil, &block)
      source ||= block
      @path.add_dependency(name, source)
    end
  end
end
