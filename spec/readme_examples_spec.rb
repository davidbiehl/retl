require "spec_helper"

describe "Readme Examples" do 
  context "Available Steps" do 
    it "Transform" do 
      my_path = Retl::Path.new do
        filter do |row|
          row[:first_name] == "David"
        end

        transform do |row|
          row[:full_name] = row[:first_name] + " " + row[:last_name]
        end
      end

      data = [
        { first_name: "David"  , last_name: "Biehl" },
        { first_name: "Indiana", last_name: "Jones" }
      ]

      result = my_path.transform(data)
      result.to_a
      #=> [ { full_name: "David", last_name: "Biehl", full_name: "David Biehl" } ]

      expect(result.count).to eq(1)
      result.each do |data|
        expect(data).to have_key(:full_name)
      end
    end
  end
end