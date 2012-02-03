module Soca
  class Plugin
    attr_reader :pusher
    attr_accessor :options

    def self.name(plugin_name)
      @@plugins ||= {}
      @@plugins[plugin_name] = self
    end

    def self.plugins
      @@plugins ||= {}
    end

    def initialize(pusher, options = {})
      @pusher = pusher
      @options = options
    end

    def logger
      Soca.logger
    end

    def app_dir
      pusher.app_dir
    end

    def config
      pusher.config
    end

  end
end
