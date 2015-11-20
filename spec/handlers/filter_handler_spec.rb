require "spec_helper"
require_relative "handlers_context"

describe Retl::FilterHandler do 
  include_context :handlers

  subject { Retl::FilterHandler.new(step) }
  let(:step) { Proc.new { |data, context| data[:name] == "David"} }

  it "pushes out data that matches the filter" do 
    data = {name: "David"}
    subject.push_in(data, context)

    expect(subject.output).to eq([data])
  end

  it "doesn't push out data that doesn't match the filter" do 
    subject.push_in({name: "Elizabeth"}, context)

    expect(subject.output).to eq([])
  end

  it_behaves_like "a handler"
end