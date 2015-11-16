module DataPath
  class TransformStep
    def initialize(action)
      @action = action
    end

    def call(data, context)
      context.execute_step(@action, data)
      data
    end
  end
end