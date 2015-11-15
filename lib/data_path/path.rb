require "data_path/path_builder"

module DataPath
  class Path
    include Enumerable

    def initialize(source, &block)
      @source = source
      @steps = []
      @builder = PathBuilder.new(@steps, &block)
    end

    def each
      @source.each do |data|
        catch(:skip) do 
          @steps.each do |step|
            data = step.call(data)
          end
          yield(data)
        end
      end
    end
  end
end