module Soca
  class Push
    attr_accessor :app_dir, :config_path
    attr_reader :config
    
    def initialize(app_dir, config_path = nil)
      self.app_dir     = File.expand_path(app_dir) + '/'
      self.config_path = config_path
      load_config
    end
    
    def config_path=(config_path)
      @config_path = config_path || File.join(app_dir, 'config.js')
    end
    
    def load_config
      @config = JSON.parse(File.read(config_path))
    end
    
    def bundle_js
      jimfile = File.join(app_dir, 'Jimfile')
      if File.readable?(jimfile)
        Dir.chdir app_dir do
          Jim.logger = Soca.logger
          bundler = Jim::Bundler.new(File.read(jimfile), Jim::Index.new(app_dir))
          bundler.bundle!
        end
      end
    end
    
    def build
      final_hash = {}
      bundle_js
      Dir.glob(app_dir + '**/**') do |path|
        next if File.directory?(path)
        final_hash = map_file(path, final_hash)
      end
      final_hash
    end
    
    private
    def map_file(path, hash)
      file_data = File.read(path)
      base_path = path.gsub(app_dir, '')
      if map = mapped_directories.detect {|k,v| k =~ base_path }
        if map[1] 
          base_path = base_path.gsub(map[0], map[1])
        else
          return hash
        end
      end
      parts = base_path.gsub(/^\//, '').split('/')
      current_hash = hash
      while !parts.empty?
        part = parts.shift
        if parts.empty?
          current_hash[part] = file_data
        else
          current_hash[part] ||= {}
          current_hash = current_hash[part]
        end
      end
      hash
    end
    
    def mapped_directories
      return @mapped_directories if @mapped_directories
      map = {}
      config['mapDirectories'].collect {|k,v| map[/^#{k}/] = v }
      @mapped_directories = map
    end
    
  end
end