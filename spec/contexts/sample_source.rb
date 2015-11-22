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

shared_context "sample source" do 
  let(:source) { SampleData.new }
end