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
        catch(:skip) do 
          yield @path.call(data, context)
        end
      end
    end
  end
end