module Soca
  class Plugin
    attr_reader :pusher

    def initialize(pusher)
      @pusher = pusher
    end

    def run
      raise "you need to subclass plugin and provide your own logic, please"
    end

  end
end
