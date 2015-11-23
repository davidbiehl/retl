module Retl
  class NextDescription
    def initialize(default="unknown")
      @default = default
      reset
    end

    def reset
      @next_description = @default
    end

    def describe_next(description)
      @next_description = description
    end

    def take
      description = @next_description
      reset
      description
    end
  end
end