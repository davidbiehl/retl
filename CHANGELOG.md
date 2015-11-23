# Change Log

### 0.0.5

- Bug Fix: transform was mutating source data. Instead we just want it to 
  mutate a duplicate and pass that along.
- New Feature: adds a configuration block to alter the behavior of rETL
- New Feature: error handling. Errors can simple be raised (for development)
  or be captured so they can be evaluated later (for production)

### 0.0.4

- Bug Fix: fixes memoized fork results
- Bug Fix: fixes memoized transformation results
- New Feature: added the `path` step to include other paths
- New Feature: paths that include other paths can now resolve their dependencies
  with a hash or a block
- Improvement: Dependencies that don't define a block will raise an
  ArgumentError if the dependency is not resolved during translation. The block
  then becomes the default value of the dependency when it is not passed in.
- Specs: Added specs are all of the README examples.


### 0.0.3

- Proof of concept phase; too much going on too fast.
