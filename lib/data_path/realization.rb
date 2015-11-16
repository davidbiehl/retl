module DataPath
  class Realization
    include Enumerable
    
    def initialize(enumerable, path)
      @enumerable, @path = enumerable, path
    end

    def each(&block)
      @enumerable.each do |data|
        catch(:skip) do 
          yield @path.call(data)
        end
      end
    end
  end
end