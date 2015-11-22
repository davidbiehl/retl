require "spec_helper"

describe "Explodes Data" do 
  include_context "sample source"

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