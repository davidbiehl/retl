require "data_path/path_builder"
require "data_path/realization"
require "data_path/context"

module DataPath
  # A Path is a blueprint for transforming data
  #
  # A Path is a sequence of steps that are executed on data in order to 
  # transform it.
  # 
  # Paths can be built with a block using the API defined in the {#PathBuilder}.
  #
  # Steps are added to the Path with the {#add_step} method.
  #
  # A Path can act on a single piece of data with the {#call} method.
  #
  # A Path can transform a list of data with the {#realize} method.
  #
  # @example
  #   path = DataPath::Path.new do 
  #     step do |data|
  #       data[:something] = "some value"
  #       data
  #     end
  #
  #     calculate(:something_else) do 
  #       "some other value"
  #     end
  #     
  #     transform do |data|
  #       data[:something_together] = data[:something] + data[:something_else]
  #     end
  #   end
  #
  #   path.realize(data)
  #
  class Path
    attr_reader :steps, :source, :dependencies

    # Initializes a new Path
    #
    # @param parent [Path] - a Path to inherit from
    def initialize(parent=nil, &block)
      @steps        = []
      @outlets      = {}
      @dependencies = {}
      
      add_step parent.dup if parent
      build(&block)       if block
    end

    # Builds a Path with the PathBuilder DSL
    #
    # @return [void]
    def build(&block)
      PathBuilder.new(self, &block)
    end

    # Initializer when copying a Path
    #
    # When a Path is copied, a copy of the Path's steps need to be copied
    # as well. That was if additional steps are added to the original Path
    # they won't be part of the copied Path.
    def initialize_copy(source)
      @steps   = source.steps.dup
      @outlets = {}
    end

    # Adds a step to the Path
    #
    # A step is called with data and is expected to return complete, modified
    # data.
    #
    # Steps are executed in the sequence they are added.
    #
    # @param step [#call(data)] the step to take
    #
    # @return [void]
    def add_step(step)
      @steps << step
    end

    # Accessor for the Path's outlets
    #
    # @return [Hash<name, Path>] 
    def outlets
      @outlets
    end

    # Execuutes the Path with the given data
    #
    # Currently the DSL mostly supports Hash based data, so this expects a 
    # Hash.
    #
    # @param data    [Hash]    the data that will be transformed by the Path
    # @param context [Context] the execution context for the transformation
    #
    # @return [Hash] the transformed data
    def call(data, context=Context.new(self))
      @steps.reduce(data) do |result, step|
        context.execute_step(step, result.dup)
      end
    end

    # Adds an outlet to the Path
    #
    # Outlets can be accessed via #outlets
    #
    # @example
    #   path.add_outlet(:river, other_path)
    #   path.outlets[:river]
    #
    # @param name   [Symbol] the name of the outlet
    # @param outlet [Path]   the Path of the other outlet
    #
    # @return [void]
    def add_outlet(name, outlet)
      @outlets[name] = outlet 
    end

    # Adds a depdency to the Path
    #
    # @param name [Symbol] the name of the outlet 
    #   (should be a valid Ruby method)
    # @param source [#call] a callable object that will return the depdency
    #
    # @return [void]
    def add_dependency(name, source)
      @dependencies[name] = source
    end

    # Executes the Path with data
    #
    # @param [#each] the data that will be processed by the Path
    #
    # @return [Realization] the realization of the Path with the data
    def realize(enumerable)
      Realization.new(enumerable, self)
    end
  end
end