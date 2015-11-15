module DataPath
  class TransformStep
    def initialize(action)
      @action = action
    end

    def call(data)
      data.dup.tap do |dup|
        @action.call(dup)
      end
    end
  end
end