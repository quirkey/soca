jimfile = File.join(app_dir, 'Jimfile')
logger.debug "bundling js"
Jim.logger = Soca.logger
bundler = Jim::Bundler.new(File.read(jimfile), Jim::Index.new(app_dir))
bundler.bundle!