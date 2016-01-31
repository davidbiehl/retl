# rETL

**R**uby
**E**xtract
**T**ransform
**L**oad

rETL is a gem with a rich DSL for ETL (extract, transform, load) projects in 
Ruby.

## Warning!

This gem is a work in progress and the API is subject to change. Please use
at your own risk! The API and DSL will stabilize on version 0.1.0.

## Transforming Data

The core construct for transforming data is called a **Path**. A path describes
how data should be transformed. rETL has a rich DSL that is intended to work on
Hash objects, but it is not limited strictly to Hashes.

### Defining a Path

A path is composed of **Steps**. Each step is intended to act on a single unit
of data that is passed into a block (like a row from a database query). The
steps are executed in the order they are defined. In other words, the data
passes through each step until it is completely transformed. In order to keep
the Path easy to understand and maintain, each step should be responsible for a
single action on a row.

This path will `filter` data by `:first_name`, and then `transform` it by adding
a `:full_name` key.

```
my_path = Retl::Path.new do
  filter do |row|
    row[:first_name] == "David"
  end

  transform do |row|
    row[:full_name] = row[:first_name] + " " + row[:last_name]
  end
end
```

Once a path is defined, it can be used to transform data with the
`#transform(enumerable, options={})` method. A `Transformation` object is
returned, which is `Enumerable`.

```
data = [
  { first_name: "David"  , last_name: "Biehl" },
  { first_name: "Indiana", last_name: "Jones" }
]

result = my_path.transform(data)
result.to_a
#=> [ { full_name: "David", last_name: "Biehl", full_name: "David Biehl" } ]
```

### Available Steps

There are several steps available in the rETL DSL that will transform data in
different ways.

#### Transform

The `transform` step will mutate the data passed into the block. The return
value of a `transform` step is ignored. See the `:full_name` example above.

#### Replace

The `replace` step will replace the data with the return value of the block. A
common use is to use `replace` as the first step to convert incoming objects
into hashes.

```
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
#=>   {:first_name=>"David", :last_name=>"Biehl", :age=>33}, 
#=>   {:first_name=>"Indiana", :last_name=>"Jones", :age=>50}
#=> ]
```

#### Filter & Reject

The `filter` step uses a predicate block to determine if the data should proceed
to the next step. Conversely, `reject` will discard data if the predicate is
truthy. `select` is an alias for `filter`.

```
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
#=> [{:name=>"David", :age=>33, :adult_or_child=>"adult"}]

```

#### Calculate

The `calculate` step will calculate a single key on a Hash with the return value
of the block. For example, `calculate` can be used instead of `transform` from
the first example. `calc` is a short-hand alias for `calculate`.

```
my_path = Retl::Path.new do
  calculate(:full_name) do |row|
    row[:first_name] + " " + row[:last_name]
  end
end
```

#### Inspect

`inspect` steps cannot change the incoming data, and the return value of the
block is ignored. These steps are intended for debugging, testing or logging
purposes.

```
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
```

#### Fork

Paths can be forked for alternate results with the `fork(name)` step. The forked
data can then be accessed on the result with the `#forks(name)` method. Forks
are unaffected by any steps that take place after the fork is defined.

```
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
```

#### Explode

The `explode` step adds additional data to the Path. The return value of the
block should respond to `#each`, like an Array.

```
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
```

#### Path Reuse

In rETL, paths can be re-used with the `path` step. Common Paths can be
defined to ensure that calculations yield consistent results throughout the
entire ETL project. Consistent data and meanings will make the data warehouse
easier to understand for data consumers.

```
AdultOrChild = Retl::Path.new do 
  calculate(:adult_or_child) do |row|
    row[:age] >= 18 ? "adult" : "child"
  end
end

my_path = Retl::Path.new do 
  path AdultOrChild

  ### perform other steps, if necessary
end

result = my_path.transform([{age: 3}])
result.to_a
#=> [ { age: 3, adult_or_child: "child" } ]
```

#### Dependencies

Dependencies can be defined with the `depends_on(name)`. The value of the
dependency is accessible inside of each step by its name. In this example, we'll
define an `age_lookup` dependency.

```
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
```

##### Dependency Injection

Dependencies can also be injected when the transformation takes place. This is
useful for testing by passing in mocks or stubs. Also, concrete results from
other paths can be merged merged into a single path making data integration
possible.

```
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
```

#### Path Reuse with Dependencies

The `AdultOrChild` path above isn't very flexible. It depends on an `:age` key
to be present in the hash. What if our data uses a different key, like
`:years_since_birth`? rETL can make this more flexible by adding dependencies.

```
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
```

### Error Handling

Sometimes errors happen while a step is being performed. By default, errors are
wrapped in a `StepExecutionError` and the transformation will abort (this
can be changed with configuration, however). The `StepExecutionError` will
provide context to aid in debugging the error.

Pay attention to the `desc` step in the path below. `desc` simply describes the
next step. Not only does this provide good documentation, but the description
will also be available in the `StepExecutionError` to make debugging easier.

```
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
  #=> "bad age (at step: Check for sane ages))"

  e.step_description
  #=> "Check for sane ages"

  e.input_data
  #=> { :age => 1000 }

  e.current_data
  #=> { :age => 1000, :five => 5 }
end
```

rETL can be globally configured to continue transforming data despite an error
like so:

```
Retl.configure do |config|
  config.raise_errors = false
end
```

With this configuration change, the transformation would continue to process the
data and errors would be accessible via the `#errors` method on the
transformation.

```
# same path and data as above

result = my_path.transform(data)

result.to_a
#=> [ { age: 3, five: 5 } ]   # the error data isn't in the result

result.errors.to_a
#=> [ StepExecutionError ]    # the error information is still available, see
                              # above for use.
```

### Multi-Thread Support

Since extracting and loading can be I/O intense operations, it makes sense
to run them in their own threads. This can be done with the `Path#transform!`
method. It works just like `Path#transform` only it will separate extration,
transformation and loading into separate threads.

```
path.transform!(data)
```

## Roadmap

Currently the rETL gem's strengths are transforming data and code reuse. However
this is only one part of an ETL project. I haven't even started on extracting or
loading. Fortunately, the contract for transformation is very simple.

```
path.transform(Enumerable) 
#=> Enumerable
```

Enumerales in, Enumerales out. This makes the application of the gem pretty much
universal for any type of data transformation requirement in Ruby.

### Next Steps

- Tracing and logging
- Extract patterns
- Load patterns

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'retl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install retl

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/davidbiehl/retl. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
