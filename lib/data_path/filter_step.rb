module DataPath
  class FilterStep
    def initialize(predicate)
      @predicate = predicate
    end

    def call(data, context)
      throw(:skip) unless context.execute_step(@predicate, data)
    end
  end
end