module DataPath
  class Context
    def initialize(path)
      @path  = path

      @path.dependencies.each do |name, dependency|
        self.class.send(:define_method, name) { dependency.call }
      end
    end

    def execute_step(step, data)
      if step.is_a?(Proc)
        instance_exec(data, self, &step)
      else
        if step.method(:call).arity == 2
          step.call(data, self)
        else
          step.call(data)
        end
      end
    end
  end
end