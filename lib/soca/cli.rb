require 'thor'
require 'thor/actions'

module Soca
  class CLI < Thor
    include Thor::Actions

    attr_accessor :app_dir,
                  :config_file

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
    end

    def init

    end

    def generate

    end

    def url(env = 'default')
      puts pusher(env).app_url
    end

    def open(env = 'default')
      `open #{pusher(env).app_url}`
    end

    def push(env = 'default')
      pusher(env).push!
    end

    def build(env = 'default')
      require 'pp'
      pp pusher(env).build
    end

    def compact(env = 'default')
      pusher(env).compact
    end

    def json(env = 'default')
      puts pusher(env).json
    end

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
