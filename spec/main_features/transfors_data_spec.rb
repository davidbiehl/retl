require 'spec_helper'

describe "Transforms Data" do 
  include_context "sample source"

  it "transforms data with `transform`" do 
    path = Retl::Path.new do 
      transform do |row|
        row[:type] = row[:age] >= 18 ? "adult" : "child"
      end
    end

    path.transform(source).each do |data|
      expect(data).to have_key(:type)
    end
  end
end