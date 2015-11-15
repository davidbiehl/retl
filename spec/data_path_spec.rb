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
    path = DataPath::Path.new(source) do 
      transform TypeTransformation
    end

    path.each do |data|
      expect(data).to have_key(:type)
    end
  end

  it "replaces data" do 
    path = DataPath::Path.new(source) do 
      step do |data|
        data[:age]
      end
    end

    expect(path.to_a).to eq([33, 35, 5])
  end

  it "filters data" do 
    path = DataPath::Path.new(source) do 
      transform TypeTransformation

      filter do |data|
        data[:type] == "adult"
      end
    end

    expect(path.count).to eq(2)
  end

  it "has multiple outlets" do 
    path = DataPath::Path.new(source) do 
      transform TypeTransformation

      outlet :adults do 
        filter do |data|
          data[:type] == "adult"
        end
      end

      outlet :children do 
        filter do |data|
          data[:type] == "child"
        end
      end
    end

    expect(path.outlets[:adults].count).to eq(2)
    expect(path.outlets[:children].count).to eq(1)
  end
end
