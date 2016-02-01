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
      @path.add_step(ReplaceStep.new(step || block), @next_descripion.take)
    end
    alias_method :replace, :step

    def transform(action=nil, &block)
      @path.add_step(TransformStep.new(action || block), @next_descripion.take)
    end

    def filter(predicate=nil, &block)
      @path.add_step(FilterStep.new(predicate || block), @next_descripion.take)
    end
    alias_method :select, :filter

    def fork(name, &block)
      @path.add_fork(name, &block)
    end

    def inspect(action=nil, &block)
      @path.add_step(InspectStep.new(action || block), @next_descripion.take)
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
      @path.add_step(ExplodeStep.new(action || block), @next_descripion.take)
    end

    def path(path, dependencies={}, &block)
      @path.add_step(PathStep.new(path, dependencies, &block), @next_descripion.take)
    end

    def desc(step_description)
      @next_descripion.describe_next(step_description)
    end
  end
end
