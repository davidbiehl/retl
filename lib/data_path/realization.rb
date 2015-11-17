require "data_path/context"

module DataPath
  class Realization
    include Enumerable
    
    def initialize(enumerable, path)
      @enumerable, @path = enumerable, path
    end

    def each(&block)
      context = Context.new(@path)
      @enumerable.each do |data|
        @path.call(data, context).each do |data|
          yield data
        end
      end
    end

    def load_into(*destinations)
      destinations = Array(destinations)

      each do |data|
        destinations.each do |destination|
          destination << data
        end
      end

      destinations.each do |destination|
        destination.close if destination.respond_to?(:close)
      end
    end
  end
end