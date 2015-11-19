require "data_path/event_router"

module DataPath
  class Context
    def initialize(path, options={})
      path.dependencies.each do |name, dependency|
        self.class.send(:define_method, name) { dependency.call(options) }
      end

      @_events = EventRouter.new
    end

    def execute_step(step, data)
      if step.is_a?(Proc)
        instance_exec(data, self, &step)
      else
        if step.method(:call).arity.abs == 2
          step.call(data, self)
        else
          step.call(data)
        end
      end
    end

    def _events
      @_events
    end
  end
end