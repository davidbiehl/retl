class Configuration
  attr_accessor :raise_errors

  def initialize
    reset!
  end

  def reset!
    self.raise_errors = true
  end
end