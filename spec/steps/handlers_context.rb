RSpec.shared_context :steps do 
  let(:data) { { name: "David", age: 33 } }
  let(:path) { Retl::Path.new }
  let(:context) { Retl::Context.new(path) }
end

RSpec.shared_examples "a step" do 
  it "always clears the output" do 
    subject.push_in(data, context)
    subject.output
    expect(subject.output).to be_empty
  end
end