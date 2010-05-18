module Soca
  class CLI
    attr_accessor :args, :appdir, :config_file
    
    def initialize(args)
      self.args = args
      parse_options(args)
      self.appdir ||= File.expand_path(Dir.pwd)
      puts self.inspect
    end
    
    # method called by the bin directly after initialization. 
    def run
      command = @args.shift
      if command && respond_to?(command)
        self.send(command, *@args)
      elsif command.nil? || command.strip == ''
        cheat
      else 
        logger.error "No action found for #{command}. Run -h for help."
      end
    rescue ArgumentError => e
      logger.error "#{e.message} for #{command}"
    rescue => e
      logger.error e.message + " (#{e.class})"
    end
    
    def cheat
      
    end
    
    def push(env = 'default')
      pusher = Soca::Push.new(appdir, env, config_file)
      pusher.push!
    end
    
    def logger
      Soca.logger
    end
    
    private
     def parse_options(runtime_args)
       OptionParser.new("", 24, '  ') do |opts|
         opts.banner = "Usage: soca [options] [command] [args]"

         opts.separator ""
         opts.separator "soca options:"

         opts.on("--appdir=[appdir]", "set the appdir to work with. assumes the current directory") {|d|
           self.appdir = d
         }
         
         opts.on("-c [config.js]", "use a specific soca config.js") {|c| 
           self.config_file = c
         }

         opts.on("-d", "--debug", "set log level to debug") {|d|
           logger.level = Logger::DEBUG
         }

         opts.on("-o", "--stdout", "write output of commands (like bundle and compress to STDOUT)") {|o| 
           logger.level = Logger::ERROR
           self.stdout = true
         }

         opts.on("-v", "--version", "print version") {|d|
           puts "soca #{Soca::VERSION}"
           exit
         }

         opts.on_tail("-h", "--help", "Show this message.") do
           puts opts.help
           exit
         end

       end.parse! runtime_args
     rescue OptionParser::MissingArgument => e
       logger.warn "#{e}, run -h for options"
       exit
     end

  end
end