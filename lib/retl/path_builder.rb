require "retl/steps/transform_step"
require "retl/steps/filter_step"
require "retl/steps/inspect_step"
require "retl/steps/explode_step"
require "retl/steps/path_step"
require "retl/steps/replace_step"
require "retl/next_description"


module Retl
  class PathBuilder
    def initialize(path, &block)
      @path = path
      @next_descripion = NextDescription.new
      instance_eval(&block)
    end

    def step(step=nil, &block)
      @path.add_step(step || block, @next_descripion.take)
    end

    def replace(action=nil, &block)
      step(ReplaceStep.new(action || block))
    end

    def transform(action=nil, &block)
      step(TransformStep.new(action || block))
    end

    def filter(predicate=nil, &block)
      step(FilterStep.new(predicate || block))
    end
    alias_method :select, :filter

    def fork(name, &block)
      @path.add_fork(name, &block)
    end

    def inspect(action=nil, &block)
      step(InspectStep.new(action || block))
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
      step(ExplodeStep.new(action || block))
    end

    def path(path, dependencies={}, &block)
      step(PathStep.new(path, dependencies, &block))
    end

    def desc(step_description)
      @next_descripion.describe_next(step_description)
    end
  end
end
