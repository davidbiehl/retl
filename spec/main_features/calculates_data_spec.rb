require "spec_helper" 

describe "Calculates Data" do 
  include_context "sample source"
  
  it "can calculate single keys with `calculate`" do 
    rspec = self

    path = Retl::Path.new do 
      calculate(:upper_name) do |data|
        data[:name].upcase
      end

      inspect do |data|
        rspec.expect(data[:upper_name]).to rspec.eq(data[:name].upcase)
      end

      calc(:lower_name) do |data|
        data[:name].downcase
      end

      inspect do |data|
        rspec.expect(data[:lower_name]).to rspec.eq(data[:name].downcase)
      end
    end

    path.transform(source)
  end
end