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

    it "Replace" do 
      users = [
        ["David", "Biehl", 33],
        ["Indiana", "Jones", 50]
      ]

      my_path = Retl::Path.new do
        replace do |row|
          { first_name: row[0], last_name: row[1], age: row[2] }
        end

        # perform other steps with the hash
      end

      result = my_path.transform(users)
      result.to_a
      #=> [
      #=>   { :first_name=>"David"  , :last_name=>"Biehl", :age=>33 }, 
      #=>   { :first_name=>"Indiana", :last_name=>"Jones", :age=>50 }
      #=> ]

      expect(result.count).to eq(2)
      result.each do |data|
        expect(data).to include(:first_name, :last_name, :age)
      end
    end

    it "Filter & Reject" do 
      data = [
        {name: "David"  , age: 33},
        {name: "Indiana", age: 50},
        {name: "Sully"  , age: 7},
        {name: "Boo"    , age: 3}
      ]

      my_path = Retl::Path.new do 
        transform do |row|
          row[:adult_or_child] = row[:age] >= 18 ? "adult" : "child"
        end

        reject do |row| 
          row[:adult_or_child] == "child" 
        end

        select do |row|    # `select` is an alias of `filter`
          row[:age].odd?
        end
      end

      result = my_path.transform(data)
      result.to_a
      #=> [ { :name=>"David", :age=>33, :adult_or_child=>"adult" } ]

      expect(result.count).to eq(1)
    end

    it "Calculate" do 
      my_path = Retl::Path.new do
        calculate(:full_name) do |row|
          row[:first_name] + " " + row[:last_name]
        end
      end

      data = [
        { first_name: "David"  , last_name: "Biehl" },
        { first_name: "Indiana", last_name: "Jones" }
      ]

      result = my_path.transform(data)
      result.to_a
      #=> [ 
      #=>   { full_name: "David"  , last_name: "Biehl", full_name: "David Biehl" },
      #=>   { full_name: "Indiana", last_name: "Jones", full_name: "Indiana Jones" }
      #=> ]

      expect(result.count).to eq(2)
      result.each do |data|
        expect(data).to have_key(:full_name)
      end
    end

    context "Inspect" do 
      # rspec example

      it "adds a full name" do 
        rspec = self

        my_path = Retl::Path.new do
          calc(:full_name) do |row|
            row[:first_name] + " " + row[:last_name]
          end
        
          inspect do |row|
            rspec.expect(row).to rspec.include(full_name: "Indiana Jones")
          end
        end

        my_path.transform([ { first_name: "Indiana", last_name: "Jones"} ]).to_a
      end
    end

    it "Fork" do 
      data = [
        { name: "David"  , age: 33 },
        { name: "Indiana", age: 50 },
        { name: "Sully"  , age: 7 },
        { name: "Boo"    , age: 3 }
      ]

      my_path = Retl::Path.new do 
        transform do |row|
          row[:adult_or_child] = row[:age] >= 18 ? "adult" : "child"
        end

        fork(:adults) do 
          filter do |row|
            row[:adult_or_child] == "adult"
          end
        end

        fork(:children) do 
          filter do |row|
            row[:adult_or_child] == "child"
          end
        end

        reject do |row| 
          true  # oops, rejecting everything after the forks.  
        end
      end

      result = my_path.transform(data)

      result.forks(:adults).to_a
      #=> [ { name: "David", ... }, { name: "Indiana", ... } ]

      result.forks(:children).to_a
      #=> [ { name: "Sully", ... }, { name: "Boo", ... } ]

      result.to_a
      #> [ ]

      expect(result.forks(:adults).count).to eq(2)
      expect(result.forks(:children).count).to eq(2)
      expect(result.count).to eq(0)
    end
  end
end