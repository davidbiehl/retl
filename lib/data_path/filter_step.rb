module DataPath
  class FilterStep
    def initialize(predicate)
      @predicate = predicate
    end

    def call(data)
      throw(:skip) unless @predicate.call(data)
    end
  end
end