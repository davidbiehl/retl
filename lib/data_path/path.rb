require "data_path/path_builder"
require "data_path/realization"
require "data_path/context"
require "data_path/step_handler"
require "data_path/explode_handler"

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
    attr_reader :steps, :source, :dependencies, :forks

    # Initializes a new Path
    #
    # @param parent [Path] - a Path to inherit from
    def initialize(parent=nil, &block)
      @steps        = []
      @forks        = {}
      @dependencies = {}
      
      add_step parent.dup, handler: ExplodeHandler if parent
      build(&block) if block
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
      @steps = source.steps.dup
      @forks = {}
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
    def add_step(step, handler: StepHandler)
      @steps << handler.new(step)
    end

    # Execuutes the Path with the given data
    #
    # Currently the DSL mostly supports Hash based data, so this expects a 
    # Hash.
    #
    # Since a piece of data can now be exploded, this method will always
    # return an Array. 
    #
    # @param data    [Hash]    the data that will be transformed by the Path
    # @param context [Context] the execution context for the transformation
    #
    # @return [Array<Hash>] the transformed data
    def call(data, context=Context.new(self))
      @steps.reduce([data]) do |queue, handler|
        queue.each do |data|
          handler.push_in(data, context)
        end
        handler.output
      end
    end

    # Adds an fork to the Path
    #
    # Forks can be accessed via #forks
    #
    # @example
    #   path.add_fork(:river) do 
    #     filter { |data| data[:is_wet] }
    #   end
    #   path.forks[:river]
    #
    # @param name [Symbol] the name of the fork
    #
    # @return [void]
    def add_fork(name, &block)
      fork = Path.new(self, &block)
      @forks[name] = fork 
    end

    # Adds a depdency to the Path
    #
    # @param name [Symbol] the name of the dependency
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
    # @option options that will be passed to #depends_on for the context
    #
    # @return [Realization] the realization of the Path with the data
    def realize(enumerable, options={})
      Realization.new(enumerable, self, options)
    end
  end
end