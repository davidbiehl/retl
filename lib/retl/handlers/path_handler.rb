require_relative "handler"

module Retl
  class PathHandler < Handler
    def initialize(path, dependencies={}, &block)
      super()
      @path = path
      dependencies.merge!(block.call) if block
      @context = Context.new(@path, dependencies)
    end

    def push_in(data, context)
      @context.execute_step(@path, data).each do |result|
        push_out(result)
      end
    end
  end
end