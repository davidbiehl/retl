RSpec.shared_context :handlers do 
  let(:data) { { name: "David", age: 33 } }
  let(:path) { Retl::Path.new }
  let(:context) { Retl::Context.new(path) }
end

RSpec.shared_examples "a handler" do 
  it "always clears the output" do 
    subject.push_in(data, context)
    subject.output
    expect(subject.output).to be_empty
  end
end