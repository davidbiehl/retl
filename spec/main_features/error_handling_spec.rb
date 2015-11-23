require "spec_helper"

describe "Error Handling" do 
  include_context "sample source"

  let(:path) do  
    Retl::Path.new do 
      desc "calculates the number 4"
      calculate(:four) do |row|
        4
      end

      desc "the description"
      inspect do |row|
        raise StandardError, "David's aren't allowed" if row[:name] == "David"
      end

      desc "calculate the number 5"
      calculate(:five) { 5 }
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
      expect { path.transform(source).to_a }.to raise_error(Retl::StepExecutionError)
    end
  end

  context "with `config.raise_errors = false`" do 
    let(:raise_errors) { false }

    it "won't abort the transformation" do 
      expect { path.transform(source).to_a }.to_not raise_error
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

    it "will still have the good rows in the result" do 
      result = path.transform(source)
      expect(result.to_a.count).to eq(2)
    end
  end

  context "PathExecutionError" do 
    let(:raise_errors) { false }

    subject do 
      result = path.transform(source)
      result.to_a
      result.errors.first
    end

    it "has the cause of the error" do 
      expect(subject.cause).to be_a(StandardError)
      expect(subject.message).to start_with("David's aren't allowed")
    end

    it "has the input data" do 
      expect(subject.input_data).to include({name: "David"})
      expect(subject.input_data).to_not include({four: 4})
    end

    it "has the current data" do 
      expect(subject.current_data).to include({four: 4})
    end

    it "will have the step's description" do 
      expect(subject.step_description).to eq("the description")
    end
  end
end