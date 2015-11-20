require 'spec_helper'

class SampleData
  include Enumerable

  def each
    yield({age: 33, name: "David", gender: "M"})
    yield({age: 35, name: "Elizabeth", gender: "F"})
    yield({age: 5 , name: "Pake", gender: "M"})
  end
end

class TypeTransformation
  def self.call(data)
    data[:type] = data[:age] >= 18 ? "adult" : "child"
  end
end

describe Retl do
  let(:source) { SampleData.new }

  it 'has a version number' do
    expect(Retl::VERSION).not_to be nil
  end

  it "transforms data" do 
    path = Retl::Path.new do 
      transform TypeTransformation
    end

    path.transform(source).each do |data|
      expect(data).to have_key(:type)
    end
  end

  it "replaces data" do 
    path = Retl::Path.new do 
      replace do |data|
        data[:age]
      end
    end

    expect(path.transform(source).to_a).to eq([33, 35, 5])
  end

  it "filters data" do 
    path = Retl::Path.new do 
      transform TypeTransformation

      filter do |data|
        data[:type] == "adult"
      end
    end

    result = path.transform(source)

    expect(result.count).to eq(2)
    result.each do |data|
      expect(data).to include(type: "adult")
    end
  end

  it "rejects data" do 
    path = Retl::Path.new do 
      transform TypeTransformation

      reject do |data|
        data[:type] == "child"
      end
    end

    expect(path.transform(source).count).to eq(2)
  end

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

  it "can inspect data without changing it" do
    rspec = self
    path = Retl::Path.new do 
      inspect do |data|
        data[:other] = "awesome"
        rspec.expect(data).to_not rspec.have_key(:type)
        data
      end
      
      transform TypeTransformation

      inspect do |data|
        rspec.expect(data).to rspec.have_key(:type)
        rspec.expect(data).to_not rspec.have_key(:other)
      end
    end

    path.transform(source).to_a
  end

  it "can calculate single keys" do 
    rspec = self

    path = Retl::Path.new do 
      calculate(:upper_name) do |data|
        data[:name].upcase
      end

      inspect do |data|
        rspec.expect(data[:upper_name]).to rspec.eq(data[:name].upcase)
      end

      calc(:lower_name) do |data|
        data[:name].downcase
      end

      inspect do |data|
        rspec.expect(data[:lower_name]).to rspec.eq(data[:name].downcase)
      end
    end

    path.transform(source)
  end

  it "can depend on other data" do 
    path = Retl::Path.new do 
      depends_on(:gender_names) do 
        {"M" => "Male", "F" => "Female"}
      end

      calc(:gender_name) do |data|
        gender_names[data[:gender]] || "Unknown"
      end
    end

    result = path.transform(source)

    result.each do |data|
      expect(data).to have_key(:gender_name)

      if data[:name] == "David"
        expect(data[:gender_name]).to eq("Male")
      end
    end
  end

  it "injects dependencies when the path is transformd" do 
    rspec = self

    path = Retl::Path.new do 
      depends_on(:weather) do |options|
        options[:weather] || (raise ArgumentError, "This path depends on the weather")
      end

      inspect do |data|
        rspec.expect(weather).to rspec.eq("rainy")
      end
    end

    path.transform(source, weather: "rainy").to_a

    expect { path.transform(source).to_a }.to raise_error(ArgumentError)
  end

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

  it "can explode data" do 
    path = Retl::Path.new do 
      transform TypeTransformation
      explode do |data|
        3.times.map do |i|
          data[:set] = i
          data
        end
      end
    end

    expect(path.transform(source).count).to eq(9)
  end
end
