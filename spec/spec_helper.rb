$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'retl'

Dir["./spec/contexts/**/*.rb"].sort.each { |f| require f}

RSpec.configure do |config|
  config.before(:each) do 
    Retl.configure { |c| c.reset! }
  end
end