require "spec_helper"

describe "Dependencies" do 
  include_context "sample source" 

  it "can depend on other data" do 
    path = Retl::Path.new do 
      depends_on(:gender_names) do 
        {"M" => "Male", "F" => "Female"}
      end

      calc(:gender_name) do |data|
        gender_names[data[:gender]] || "Unknown"
      end
    end

    result = path.transform(source)

    result.each do |data|
      expect(data).to have_key(:gender_name)

      if data[:name] == "David"
        expect(data[:gender_name]).to eq("Male")
      end
    end
  end

  it "injects dependencies when the path is transformd" do 
    rspec = self

    path = Retl::Path.new do 
      depends_on(:weather)
      
      inspect do |data|
        rspec.expect(weather).to rspec.eq("rainy")
      end
    end

    path.transform(source, weather: "rainy").to_a

    expect { path.transform(source).to_a }.to raise_error(ArgumentError)
  end

  it "raises an argument error when a dependency doesn't have a default value" do 
    path = Retl::Path.new do 
      depends_on(:something)
    end

    expect { path.transform([]) }.to raise_error(ArgumentError)
  end
end