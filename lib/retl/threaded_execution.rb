module Retl
  class ThreadedExecution < DefaultExecution
    def each(&block)
      @executed = true
      queue = Queue.new

      producer = Thread.new do 
        @enumerable.each { |item| queue.push item }
        queue.push :eoq
      end

      while((data = queue.pop) != :eoq)
        execute(data, &block)
      end

      producer.join
    end

    def load_into(*destinations)
      destinations = Array(destinations)
      queue = Queue.new

      producer = Thread.new do 
        each do |data|
          queue.push data
        end
        queue.push :eoq
      end

      while((data = queue.pop) != :eoq)
        destinations.each do |destination|
          destination << data
        end
      end

      producer.join

      destinations.each do |destination|
        destination.close if destination.respond_to?(:close)
      end
    end
  end
end