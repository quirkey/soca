require 'sass/plugin'
require 'compass'
require 'compass/logger'

module Soca
  module Plugins
    class Compass < Soca::Plugin

      name 'compass'

      def run
        Soca.logger.info "compiling compass"
        compass_from = File.join(app_dir, 'sass')
        compass_to   = File.join(app_dir, 'css')
        compass = Compass::Compiler.new(app_dir, compass_from, compass_to, Compass.sass_engine_options)
        compass.run
      end

    end
  end
end
