require "retl/version"

require "retl/path"
require "retl/configuration"

module Retl
  @configuration = Configuration.new

  class << self
    attr_reader :configuration

    def configure(&block)
      block.call(@configuration)
    end
  end

  # Your code goes here...
end
