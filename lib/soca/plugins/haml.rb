require 'haml'

module Soca
  module Plugins
    class Haml < Soca::Plugin

      name 'haml'

      def run(options={})
        @options = options

        Dir[File.join(haml_from, "**/*.haml")].each do |file|
          Soca.logger.debug "Running #{file} through Haml."
          basename = File.basename(file, ".haml")
          dir      = File.dirname(file).sub(/^#{haml_from}/,
                                            haml_to)
          new_file = basename + ".html"
          FileUtils.mkdir_p(dir) unless File.exists?(dir)

          File.open(File.join(dir, new_file), 'w') do |f|
            f << ::Haml::Engine.new(File.read(file)).render
          end
          Soca.logger.debug "Wrote to #{File.join(dir, new_file)}"
        end
      end

      private
      def haml_from
        @options.has_key?(:from) ? File.join(app_dir, @options[:from]) : File.join(app_dir, 'haml')
      end

      def haml_to
        @options.has_key?(:to) ? File.join(app_dir, @options[:to]) : File.join(app_dir, '')
      end

    end
  end
end
