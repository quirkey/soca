require 'thor'
require 'thor/actions'

module Soca
  class CLI < ::Thor
    include Thor::Actions

    attr_accessor :appdir,
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
        :type => false,
        :alias => 'v',
        :banner => "print version and exit"

    default_task :help

    def initialize(*)
      super
      if options[:version]
        say "soca #{Soca::VERSION}", :red
        exit
      end
      self.appdir      = options[:appdir] || File.expand_path(Dir.pwd)
      self.config_file = options[:config]
      self.debug       = options[:debug]
      if options[:debug]
        logger.level = Logger::DEBUG
        options[:quiet] = false
      end
      self.source_paths << File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end

    method_option "appname",
          :type => :string,
          :banner => "set the name of the application for templating. defaults to the basename of the appdir"

    desc 'init [APPDIR]', 'turns any directory into a soca app, generating a config.js'
    def init(to = nil)
      self.appdir = to if to
      self.destination_root = appdir
      @dir_mappings = {}
      Dir[appdir + '*'].each do |filename|
        basename = File.basename(filename)
        @dir_mappings[basename] = "_attachments/#{basename}"
      end
      template('config.js.erb', 'config.js')
      template('couchapprc.erb', '.couchapprc')
    end

    method_option "appname",
          :type => :string,
          :banner => "set the name of the application for templating. defaults to the basename of the appdir"

    desc 'generate [APPDIR]', 'generates the basic soca app structure'
    def generate(to = nil)
      self.appdir = to if to
      self.destination_root = appdir

      directory('hooks')
      directory('js')
      directory('css')
      directory('db')
      template('Jimfile')
      template('index.html.erb', 'index.html')
      @dir_mappings = {
        "config.js"  => "",
        "index.html" => "_attachments/index.html",
        "css"        => "_attachments/css",
        "images"     => "_attachments/images",
        "sass"       => false,
        "js"         => "_attachments/js",
        "templates"  => "_attachments/templates",
        "db"         => "",
        "Jimfile"    => false,
        "hooks"      => false
      }
      template('config.js.erb', 'config.js')
      template('couchapprc.erb', '.couchapprc')
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
      pusher(env).compact!
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
    def appname
      @appname = options[:name] || File.basename(appdir)
    end

    def logger
      Soca.logger
    end

    def pusher(env)
      Soca::Push.new(appdir, env, config_file)
    end

  end
end
