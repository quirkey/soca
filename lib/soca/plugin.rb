module Soca
  class Plugin
    attr_reader :pusher

    def self.name(plugin_name)
      @@plugins ||= {}
      @@plugins[plugin_name] = self
    end

    def self.plugins
      @@plugins ||= {}
    end

    def initialize(pusher)
      @pusher = pusher
    end

    def logger
      Soca.logger
    end

    def app_dir
      pusher.app_dir
    end

  end
end
