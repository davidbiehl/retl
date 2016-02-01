require "spec_helper" 

describe "Custom Steps" do 
  include_context "sample source"
  
  it "executes custom steps with objects that respond to #call and yield the result" do 
    class CustomStep
      def self.call(data, context)
        data[:custom] = 1
        yield data
      end
    end

    path = Retl::Path.new do 
      step CustomStep
    end

    result = path.transform(source)
    result.each do |row|
      expect(row[:custom]).to eq(1)
    end
  end

  it "executes custom steps with blocks that call a passed block" do 
    path = Retl::Path.new do 
      step do |data, &block|
        data[:custom_block] = 2
        block.call(data)
      end
    end

    result = path.transform(source)
    result.each do |row|
      expect(row[:custom_block]).to eq(2)
    end
  end
end
