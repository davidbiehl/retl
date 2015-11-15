require "data_path/filter_step"
require "data_path/transform_step"

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

    def outlet(name, &block)
      outlet = Path.new(@path.source)

      @path.steps.each do |step|
        outlet.add_step step.dup
      end
      outlet.build(&block)
      
      @path.add_outlet(name, outlet)
    end
  end
end
