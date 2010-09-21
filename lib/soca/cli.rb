require 'thor'
require 'thor/actions'

module Soca
  class CLI < Thor
    include Thor::Actions

    attr_accessor :app_dir,
                  :config_file,
                  :debug

    class_option "appdir",
          :type => :string,
          :banner => "set the application directory to work with. assumes the current directory"

    class_option "config",
        :alias => 'c',
        :type => :string,
        :banner => "use a specific soca config.js"

    class_option "debug",
        :type => :boolean,
        :default => false,
        :alias => 'd',
        :banner => "set log level to debug"

    class_option "version",
        :alias => 'v',
        :banner => "print version and exit"

    def initialize
      self.appdir      = options[:appdir] || File.expand_path(Dir.pwd)
      self.config_file = options[:config]
      self.debug       = options[:debug]
      if options[:debug]
        logger.level = Logger::DEBUG
        options[:quiet] = false
      end
    end

    desc 'init', 'turns any directory into a soca app, generating a config.js'
    def init

    end

    desc 'generate [APPDIR]', 'generates the basic soca app structure'
    def generate(appdir = nil)

    end

    desc 'url [ENV]', 'outputs the app url for the ENV'
    def url(env = 'default')
      say pusher(env).app_url
    end

    desc 'open [ENV]', 'attempts to open the url for the current app in a browser'
    def open(env = 'default')
      `open #{pusher(env).app_url}`
    end

    desc 'push [ENV]', 'builds and pushes the current app to couchdb'
    def push(env = 'default')
      pusher(env).push!
    end

    desc 'build [ENV]', 'builds the app as a ruby hash and outputs it to stdout'
    def build(env = 'default')
      require 'pp'
      pp pusher(env).build
    end

    desc 'compact [ENV]', 'runs a DB compact against the couchdb for ENV'
    def compact(env = 'default')
      pusher(env).compact
    end

    desc 'json [ENV]', 'builds and then outputs the design doc JSON for the app'
    def json(env = 'default')
      say pusher(env).json
    end

    desc 'autopush [ENV]', 'watches the current directory for changes, building and pushing to couchdb'
    def autopush(env = 'default')
      push = pusher(env)
      files = {}
      loop do
        changed = false
        Dir.glob(push.app_dir + '**/**') do |file|
          ctime = File.ctime(file).to_i
          if ctime != files[file]
            files[file] = ctime
            changed = true
            break
          end
        end

        if changed
          puts "Running push at #{Time.now}"
          push.push!

          Dir.glob(push.app_dir + '**/**') do |file|
            ctime = File.ctime(file).to_i
            if ctime != files[file]
              files[file] = ctime
            end
          end

          puts "\nWaiting for a file change"
        end

        sleep 1
      end
    end

    private
    def logger
      Soca.logger
    end

    def pusher(env)
      Soca::Push.new(appdir, env, config_file)
    end

  end
end
