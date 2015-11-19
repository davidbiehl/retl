require "spec_helper"
require_relative "handlers_context"

describe DataPath::ExplodeHandler do 
  include_context :handlers

  subject { DataPath::ExplodeHandler.new(step) }
  let(:step) { Proc.new { |data, context| data.times.map { |x| x + x } } }
  let(:data) { 3 }

  it "pushes out each member of the result array" do 
    subject.push_in(data, context)

    expect(subject.output).to eq([0, 2, 4])
  end

  it_behaves_like "a handler"
end