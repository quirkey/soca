require 'jim'

module Soca
  module Plugins
    class Jim < Soca::Plugin

      name 'jim'

      def run
        jimfile = File.join(app_dir, 'Jimfile')
        ::Jim.logger = logger
        logger.debug "bundling js"
        bundler = ::Jim::Bundler.new(File.read(jimfile), ::Jim::Index.new(app_dir))
        bundler.bundle!
      end

    end
  end
end
