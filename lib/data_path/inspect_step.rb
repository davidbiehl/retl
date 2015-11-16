module DataPath
  class InspectStep
    def initialize(action)
      @action = action
    end

    def call(data, context)
      context.execute_step(@action, data.dup)
      data
    end
  end
end