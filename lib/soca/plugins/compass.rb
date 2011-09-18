require 'sass/plugin'
require 'compass'
require 'compass/logger'

module Soca
  module Plugins
    class Compass < Soca::Plugin

      name 'compass'

      def run(options = {})
        @options = options

        Soca.logger.info "compiling compass"

        unless Soca.debug
          options = {:logger => ::Compass::NullLogger.new}.merge(options)
        end

        compass = ::Compass::Compiler.new(app_dir, compass_from, compass_to, ::Compass.sass_engine_options.merge(options || {}))
        Soca.logger.debug "compass: #{compass.inspect}"
        compass.run
      end

      private
      def compass_from
        @options.has_key?(:from) ? File.join(app_dir, @options[:from]) : File.join(app_dir, 'sass')
      end

      def compass_to
        @options.has_key?(:to) ? File.join(app_dir, @options[:to]) : File.join(app_dir, 'css')
      end
    end
  end
end
