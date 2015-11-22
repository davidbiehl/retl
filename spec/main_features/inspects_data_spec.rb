require "spec_helper"

describe "Inspects Data" do 
  include_context "sample source"
  
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
end