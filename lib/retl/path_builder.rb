require "retl/handlers/step_handler"
require "retl/handlers/transform_handler"
require "retl/handlers/filter_handler"
require "retl/handlers/inspect_handler"
require "retl/handlers/explode_handler"
require "retl/handlers/path_handler"
require "retl/next_description"


module Retl
  class PathBuilder
    def initialize(path, &block)
      @path = path
      @next_descripion = NextDescription.new
      instance_eval(&block)
    end

    def step(step=nil, handler: StepHandler, &block)
      step ||= block

      handler = handler.new(step)
      handler.description = @next_descripion.take
      
      @path.add_handler handler
    end
    alias_method :replace, :step

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

    def path(path, dependencies={}, &block)
      @path.add_handler PathHandler.new(path, dependencies, &block)
    end

    def desc(step_description)
      @next_descripion.describe_next(step_description)
    end
  end
end
