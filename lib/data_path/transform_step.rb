module DataPath
  class TransformStep
    def initialize(action)
      @action = action
    end

    def call(data)
      @action.call(data)
      data
    end
  end
end