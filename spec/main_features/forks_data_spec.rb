require "spec_helper"

describe "Forks Data" do 
  include_context "sample source"
  
  it "forks into alternate paths" do 
    path = Retl::Path.new do 
      transform TypeTransformation

      fork :adults do 
        filter do |data|
          data[:type] == "adult"
        end
      end

      fork :children do 
        select do |data|
          data[:type] == "child"
        end
      end

      filter do |data|
        data[:name] == "Whatever"
      end
    end

    result = path.transform(source)

    expect(result.count).to eq(0)
    expect(result.forks(:adults).count).to eq(2)
    expect(result.forks(:children).count).to eq(1)
  end

  it "forks have the context of the parent" do 
    rspec = self

    path = Retl::Path.new do 
      depends_on(:weather) { |opts| opts[:weather] }

      inspect do |data|
        rspec.expect(weather).to rspec.eq("rainy")
      end

      fork :fork do 
        inspect do |data|
          rspec.expect(weather).to rspec.eq("rainy")
        end
      end
    end

    result = path.transform(source, weather: "rainy")
    result.to_a
    result.forks(:fork).to_a
  end

  it "forks still work with each_slice" do 
    path = Retl::Path.new do 
      fork :fork do 
      end
    end

    count = path.transform(source).each_slice(2).reduce(0) do |sum, slice|
      sum + slice.forks(:fork).count
    end

    expect(count).to eq(3)
  end
end