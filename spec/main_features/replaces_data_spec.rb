require 'spec_helper'

describe "Replaces Data" do 
  include_context "sample source"

  it "replaces data with `replace`" do 
    path = Retl::Path.new do 
      replace do |data|
        data[:age]
      end
    end

    expect(path.transform(source).to_a).to eq([33, 35, 5])
  end
end