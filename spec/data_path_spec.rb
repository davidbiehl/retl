require 'spec_helper'

class SampleData
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

describe DataPath do
  let(:source) { SampleData.new }

  it 'has a version number' do
    expect(DataPath::VERSION).not_to be nil
  end

  it "transforms data" do 
    path = DataPath::Path.new do 
      transform TypeTransformation
    end

    path.realize(source).each do |data|
      expect(data).to have_key(:type)
    end
  end

  it "replaces data" do 
    path = DataPath::Path.new do 
      step do |data|
        data[:age]
      end
    end

    expect(path.realize(source).to_a).to eq([33, 35, 5])
  end

  it "filters data" do 
    path = DataPath::Path.new do 
      transform TypeTransformation

      filter do |data|
        data[:type] == "adult"
      end
    end

    expect(path.realize(source).count).to eq(2)
  end

  it "rejects data" do 
    path = DataPath::Path.new do 
      transform TypeTransformation

      reject do |data|
        data[:type] == "child"
      end
    end

    expect(path.realize(source).count).to eq(2)
  end

  it "has multiple outlets" do 
    path = DataPath::Path.new do 
      transform TypeTransformation

      outlet :adults do 
        filter do |data|
          data[:type] == "adult"
        end
      end

      outlet :children do 
        select do |data|
          data[:type] == "child"
        end
      end

      filter do |data|
        data[:name] == "Whatever"
      end
    end

    expect(path.outlets[:adults].realize(source).count).to eq(2)
    expect(path.outlets[:children].realize(source).count).to eq(1)
    expect(path.realize(source).count).to eq(0)
  end

  it "can inspect data without changing it" do
    path = DataPath::Path.new do 
      inspect do |data|
        data[:other] = "awesome"
        expect(data).to not_have_key(:type)
        data
      end
      
      transform TypeTransformation

      inspect do |data|
        expect(data).to have_key(:type)
        expect(data).to not_have_key(:other)
      end
    end
  end

  it "can calculate single keys" do 
    rspec = self

    path = DataPath::Path.new do 
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

    path.realize(source)
  end

  it "can depend on other data" do 
    path = DataPath::Path.new do 
      depends_on(:gender_names) do 
        {"M" => "Male", "F" => "Female"}
      end

      calc(:gender_name) do |data|
        gender_names[data[:gender]] || "Unknown"
      end
    end

    result = path.realize(source)

    result.each do |data|
      expect(data).to have_key(:gender_name)

      if data[:name] == "David"
        expect(data[:gender_name]).to eq("Male")
      end
    end
  end
end
