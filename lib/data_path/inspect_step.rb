module DataPath
  class InspectStep
    def initialize(action)
      @action = action
    end

    def call(data)
      @action.call(data.dup)
      data
    end
  end
end