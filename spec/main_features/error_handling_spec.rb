require "spec_helper"

describe "Error Handling" do 
  include_context "sample source"

  let(:path) do  
    Retl::Path.new do 
      inspect do |row|
        raise StandardError, "David's aren't allowed" if row[:name] == "David"
      end
    end
  end

  before(:each) do 
    Retl.configure do |config|
      config.raise_errors = raise_errors
    end
  end

  context "with `config.raise_errors = true`" do 
    let(:raise_errors) { true }

    it "will abort the transformation" do 
      expect { path.transform(source).to_a }.to raise_error(StandardError)
    end
  end

  context "with `config.raise_errors = false`" do 
    let(:raise_errors) { false }

    it "won't abort the transformation" do 
      expect { path.transform(source).to_a }.to_not raise_error(StandardError)
    end

    it "won't include the row with the error in the result" do 
      result = path.transform(source).to_a
      expect(result.count).to eq(2)
    end

    it "will have the errors available on the result" do 
      result = path.transform(source)
      result.to_a
      expect(result.errors.count).to eq(1)
    end
  end
end