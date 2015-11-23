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

    it "Explode" do 
      my_path = Retl::Path.new do
        explode do |number|
          number.times.map { |x| x + x + x }
        end

        filter do |number|
          number.odd?
        end
      end

      result = my_path.transform([6])
      result.to_a
      #=> [3, 9, 15]

      expect(result.to_a).to eq([3, 9, 15])
    end

    AdultOrChild = Retl::Path.new do 
      calculate(:adult_or_child) do |row|
        row[:age] >= 18 ? "adult" : "child"
      end
    end

    it "Path Reuse" do 
      my_path = Retl::Path.new do 
        path AdultOrChild

        ### perform other steps
      end

      result = my_path.transform([{age: 3}])
      result.to_a
      #=> [ { age: 3, adult_or_child: "child" } ]

      expect(result.to_a).to eq([ { age: 3, adult_or_child: "child" } ])
    end

    it "Dependencies" do 
      my_path = Retl::Path.new do
        depends_on(:age_lookup) do   # hint: the block returns the default value
          { 
            "adult" => "Adults are 18 or older",
            "child" => "Children are younger than 18"
          }
        end

        path AdultOrChild   # see previous example

        calculate(:age_description) do |row|
          age_lookup[row[:adult_or_child]]
        end
      end

      result = my_path.transform([{age: 19}])
      result.to_a
      #=> [ { age: 19, adult_or_child: "adult", age_description: "Adults are 18 or older" } ]

      expect(result.to_a).to eq([ { age: 19, adult_or_child: "adult", age_description: "Adults are 18 or older" } ])
    end

    it "Dependency Injection" do 
      my_path = Retl::Path.new do
        depends_on(:age_lookup)   # hint: without a block, the dependency must
                                  # be provided when #transform is called
        path AdultOrChild

        calculate(:age_description) do |row|
          age_lookup[row[:adult_or_child]]
        end
      end

      age_lookup_hash = { 
        "adult" => "Adults are 18 or older",
        "child" => "Children are younger than 18"
      }

      result = my_path.transform([{age: 4}], age_lookup: age_lookup_hash)
      result.to_a
      #=> [ { age: 4, adult_or_child: "child", age_description: "Children are younger than 18" } ]

      expect(result.to_a).to eq([ { age: 4, adult_or_child: "child", age_description: "Children are younger than 18" } ])
    end

    it "Path Reuse with Dependencies" do 
      FlexibleAdultOrChild = Retl::Path.new do 
        depends_on(:from) 

        depends_on(:to) do |options|
          options[:to] || :adult_or_child   # use a default value
        end

        transform do |row|
          row[to] = row[from] >= 18 ? "adult" : "child"
        end
      end


      path_with_age = Retl::Path.new do 
        path FlexibleAdultOrChild, from: :age
      end

      path_with_age_result = path_with_age.transform([{age: 33}])
      path_with_age_result.to_a
      #=> [{age: 33, adult_or_child: "adult"}]


      path_with_years_since_birth = Retl::Path.new do 
        path FlexibleAdultOrChild do
          { from: :years_since_birth, to: :age_classification }   # blocks work too
        end
      end

      result = path_with_years_since_birth.transform([{years_since_birth: 7}])
      result.to_a
      #=> [{years_since_birth: 7, age_classification: "child"}]

      expect(path_with_age_result.to_a).to eq([{age: 33, adult_or_child: "adult"}])
      expect(result.to_a).to eq([{years_since_birth: 7, age_classification: "child"}])
    end

    context "Error Handling" do 
      it "with raise errors = true" do 

        Retl.configure do |config|
          config.raise_errors = true
        end

        my_path = Retl::Path.new do 
          desc "calculates the number 5"
          calc(:five) { 5 }

          desc "Check for sane ages"
          transform do |row|
            raise StandardError, "bad age" if row[:age] > 100 
          end
        end

        data = [
          {age: 33},
          {age: 3},
          {age: 1000}
        ]

        begin
          result = my_path.transform(data).to_a
        rescue Retl::StepExecutionError => e
          e.message
          #=> bad age (at step: Check for sane ages))

          e.step_description
          #=> Check for sane ages

          e.input_data
          #=> {:age=>1000}

          e.current_data
          #=> {:age=>1000, :five=>5}
        end
      end

      it "with raise errors = false" do 
        Retl.configure do |config|
          config.raise_errors = false
        end

        my_path = Retl::Path.new do 
          desc "calculates the number 5"
          calc(:five) { 5 }

          desc "Check for sane ages"
          transform do |row|
            raise StandardError, "bad age" if row[:age] > 100 
          end
        end

        data = [
          {age: 3},
          {age: 1000}
        ]

        result = my_path.transform(data)

        result.to_a
        #=> [ { age: 3, five: 5 } ]

        result.errors.to_a
        #=> [ StepExecutionError ]
      end

    end
  end
end