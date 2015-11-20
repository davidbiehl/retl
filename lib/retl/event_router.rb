module Retl
  class EventRouter
    def initialize
      @listeners = {}
    end

    def listen_to(event_name, &block)
      @listeners[event_name] ||= []
      @listeners[event_name] << block
    end

    def trigger(event_name, args={})
      listeners = @listeners[event_name]

      if listeners
        listeners.each do |handler|
          handler.call(args)
        end
      end
    end
  end
end