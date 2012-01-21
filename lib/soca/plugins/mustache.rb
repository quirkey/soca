require 'mustache'

module Soca
  module Plugins
    class Mustache < Soca::Plugin

      name 'mustache'

      # Run the mustache plugin.
      # Available options:
      #
      # * :files - Run these files through mustache. Can be an array of patterns
      #            or a single file. The default is '*.mustache'.
      # * :vars - Additional variables to interpolate. By default the `env` and
      #             `config` are interpolated.
      #
      def before_build
        file_patterns = options[:files] || '*.mustache'
        files = Dir[*[file_patterns].flatten]
        vars = {
          :env => pusher.env,
          :config => pusher.config
        }.merge(options[:vars] || {})
        Soca.logger.debug "Mustache vars: #{vars.inspect}"
        files.each do |file|
          Soca.logger.debug "Running #{file} through mustache."
          basename = File.basename(file)
          dir      = File.dirname(file)
          parts    = basename.split(/\./)
          new_file = parts.length > 2 ? parts[0..-2].join('.') : parts[0] + ".html"
          File.open(File.join(dir, new_file), 'w') do |f|
            f << ::Mustache.render(File.read(file), vars)
          end
          Soca.logger.debug "Wrote to #{new_file}"
        end
      end

    end
  end
end
