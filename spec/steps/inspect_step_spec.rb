require "spec_helper"
require_relative "handlers_context"

describe Retl::InspectStep do 
  include_context :steps

  subject { Retl::StepHandler.new Retl::InspectStep.new(step) }
  let(:step) { Proc.new { |data, context| data[:meniacal_laughter] = "hahaha!"} }

  it "doesn't change the data" do 
    original = data.dup
    subject.push_in(data, context)

    expect(subject.output).to eq([original])
  end

  it_behaves_like "a step"
end