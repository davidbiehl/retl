require "data_path/filter_step"
require "data_path/transform_step"

module DataPath
  class PathBuilder
    def initialize(steps, &block)
      @steps = steps 
      instance_eval(&block)
    end

    def step(step=nil, &block)
      step ||= block
      @steps << step
    end

    def transform(action=nil, &block)
      action ||= block
      step(TransformStep.new(action))
    end

    def filter(predicate=nil, &block)
      predicate ||= block
      step(FilterStep.new(predicate))
    end
  end
end
