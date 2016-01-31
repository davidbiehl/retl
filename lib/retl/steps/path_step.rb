module Retl
  class PathStep
    def initialize(path, dependencies={}, &block)
      @path = path
      dependencies.merge!(block.call) if block
      @context = Context.new(@path, dependencies)
    end

    def call(data, context)
      @context.execute_step(@path, data).each do |result|
        yield result
      end
    end
  end
end