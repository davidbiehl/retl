require "spec_helper"
require_relative "handlers_context"

describe Retl::TransformStep do 
  include_context :steps

  subject { Retl::StepHandler.new Retl::TransformStep.new(step) }
  let(:step) { Proc.new { |data, context| data[:meniacal_laughter] = "hahaha!"} }

  it "changes the source data" do 
    subject.push_in(data, context)

    expect(subject.output.first).to include(meniacal_laughter: "hahaha!")
  end

  it_behaves_like "a step"
end