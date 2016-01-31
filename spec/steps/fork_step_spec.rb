require "spec_helper"
require_relative "handlers_context"

describe Retl::ForkStep do 
  include_context :steps

  subject { Retl::StepHandler.new Retl::ForkStep.new(:my_fork) }

  it "triggers a fork_data event on the context" do 
    context._events.listen_to(:fork_data) do |args|
      expect(args[:fork_name]).to eq(:my_fork)
      expect(args[:data]).to eq(data)
    end

    subject.push_in(data, context)
  end

  it "pushes the data out as-is" do 
    subject.push_in(data, context)

    expect(subject.output).to eq([data])
  end

  it_behaves_like "a step"
end