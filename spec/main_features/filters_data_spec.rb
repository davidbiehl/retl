require "spec_helper"

describe "Filters Data" do 
  include_context "sample source"

  it "filters data with `filter`" do 
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

  it "filters data with `select`" do 
    path = Retl::Path.new do 
      transform TypeTransformation

      select do |data|
        data[:type] == "adult"
      end
    end

    result = path.transform(source)

    expect(result.count).to eq(2)
    result.each do |data|
      expect(data).to include(type: "adult")
    end
  end

  it "rejects data with `reject`" do 
    path = Retl::Path.new do 
      transform TypeTransformation

      reject do |data|
        data[:type] == "child"
      end
    end

    expect(path.transform(source).count).to eq(2)
  end
end