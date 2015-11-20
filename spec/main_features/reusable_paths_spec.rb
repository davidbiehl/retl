require "spec_helper"

describe "Reusable Paths" do 
  include_context "sample source"

  let(:adults_only) do 
    Retl::Path.new do 
      depends_on(:key) { |opts| opts[:key] || :type }

      transform TypeTransformation
      filter { |data| data[key] == "adult" }
    end
  end

  it "are awesome by default" do 
    adults_only = self.adults_only
    path = Retl::Path.new do 
      path adults_only
    end

    expect(path.transform(source).count).to eq(2)
  end

  it "can have their dependencies injected with an options hash" do 
    adults_only = self.adults_only
    path = Retl::Path.new do 
      path adults_only, key: :other
    end

    expect(path.transform(source).count).to eq(0)
  end

  it "can have their dependencies injected with a block that returns a hash" do 
    adults_only = self.adults_only
    path = Retl::Path.new do 
      path(adults_only) do 
        { key: :other }
      end
    end

    expect(path.transform(source).count).to eq(0)
  end
end
