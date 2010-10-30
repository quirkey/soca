require 'coffee-script'

module Soca
  module Plugins
    class CoffeeScript < Soca::Plugin

      name 'coffeescript'

      # Run the coffeescript plugin.
      # Available options:
      #
      # * :files - Run these files through CoffeeScript. Can be an array of patterns
      #            or a single file. The default is '*.coffee'.
      # * :vars - Additional variables to interpolate. By default the `env` and
      #             `config` are interpolated.
      #
      def run(options = {})
        file_patterns = options[:files] || '*.coffee'
        files = Dir[*[file_patterns].flatten]
        vars = {
          :env => pusher.env,
          :config => pusher.config
        }.merge(options[:vars] || {})
        Soca.logger.debug "CoffeeScript vars: #{vars.inspect}"
        
        files.each do |file|
          Soca.logger.debug "Running #{file} through CoffeeScript."
          basename = File.basename(file)
          dir      = File.dirname(file)
          parts    = basename.split(/\./)
          new_file = (parts.length > 2 ? parts[0..-2].join('.') : parts[0]) + ".js"
        
          File.open(File.join(dir, new_file), 'w') do |f|
            f << ::CoffeeScript.compile(File.read(file), vars)
          end
          Soca.logger.debug "Wrote to #{new_file}"
        
        end
      end

    end
  end
end
