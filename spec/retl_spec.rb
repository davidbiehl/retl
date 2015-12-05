require 'spec_helper'

describe Retl do
  include_context "sample source"

  it "can load data to a destination" do 
    class SumReduction
      attr_reader :sum

      def initialize(key)
        @key   = key
        @sum   = 0
        @mutex = Mutex.new
      end

      def <<(data)
        @mutex.synchronize { @sum += data[@key] }
      end
    end

    path = Retl::Path.new do 
      transform TypeTransformation
      filter { |data| data[:type] == "adult" }
    end

    SumReduction.new(:age).tap do |sum|
     result = path.transform(source)
     result.load_into(sum)

     expect(sum.sum).to eq(68)
    end
  end

  it "supports threading across the ETL chain" do 
    class SlowDown
      include Enumerable

      def initialize(enum)
        @enum = enum
      end

      def each
        @enum.each do |item|
          yield(item)
          sleep 0.1
        end
      end
    end

    class SlowWrite
      def <<(row)
        sleep 0.1
      end
    end

    path = Retl::Path.new do 
      inspect do |row|
        sleep 0.1
      end
    end

    slow_source = SlowDown.new(source)

    start = Time.now
    result = path.transform!(slow_source)
    result.load_into(SlowWrite.new)
    elapsed = Time.now - start

    expect(elapsed).to be < 0.6
    expect(result.to_a).to eq(source.to_a)
  end
end
