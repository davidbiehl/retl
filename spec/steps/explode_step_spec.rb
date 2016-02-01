require "spec_helper"
require_relative "handlers_context"

describe Retl::ExplodeStep do 
  include_context :steps

  subject { Retl::StepHandler.new Retl::ExplodeStep.new(step) }
  let(:step) { Proc.new { |data, context| data.times.map { |x| x + x } } }
  let(:data) { 3 }

  it "pushes out each member of the result array" do 
    subject.push_in(data, context)

    expect(subject.output).to eq([0, 2, 4])
  end

  it_behaves_like "a step"
end