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

  it "memoizes the transformation result" do 
    path = Retl::Path.new do 
      transform TypeTransformation
      explode do |data|
        3.times.map do |i|
          data[:set] = i
          data
        end
      end
    end

    result = path.transform(source)
    result.to_a
    expect(result.count).to eq(9)
  end
end
