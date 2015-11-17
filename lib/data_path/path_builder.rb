require "data_path/step_handler"
require "data_path/transform_handler"
require "data_path/filter_handler"
require "data_path/inspect_handler"
require "data_path/explode_handler"


module DataPath
  class PathBuilder
    def initialize(path, &block)
      @path = path
      instance_eval(&block)
    end

    def step(step=nil, handler: StepHandler, &block)
      step ||= block
      @path.add_step step, handler: handler
    end

    def transform(action=nil, &block)
      action ||= block
      step(action, handler: TransformHandler)
    end

    def filter(predicate=nil, &block)
      predicate ||= block
      step(predicate, handler: FilterHandler)
    end
    alias_method :select, :filter

    def fork(name, &block)
      @path.add_fork(name, &block)
    end

    def inspect(action=nil, &block)
      action ||= block
      step(action, handler: InspectHandler)
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

    def explode(action=nil, &block)
      action ||= block
      step(action, handler: ExplodeHandler)
    end
  end
end
