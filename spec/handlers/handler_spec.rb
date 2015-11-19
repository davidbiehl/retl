require "spec_helper"
require_relative "handlers_context"

describe DataPath::Handler do 
  include_context :handlers

  subject { DataPath::Handler.new }

  it "is abstract" do 
    expect { subject.push_in(data, context) }.to raise_error(NotImplementedError)
  end
end
