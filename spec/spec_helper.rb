$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'retl'

Dir["./spec/contexts/**/*.rb"].sort.each { |f| require f}