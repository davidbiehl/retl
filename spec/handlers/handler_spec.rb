require "spec_helper"
require_relative "handlers_context"

describe Retl::Handler do 
  include_context :handlers

  subject { Retl::Handler.new }

  it "is abstract" do 
    expect { subject.push_in(data, context) }.to raise_error(NotImplementedError)
  end
end
