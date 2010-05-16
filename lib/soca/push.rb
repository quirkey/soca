module Soca
  class Push
    attr_accessor :app_dir, :config_path
    attr_reader :config
    
    def initialize(app_dir, config_path = nil)
      self.app_dir     = app_dir
      self.config_path = config_path
      load_config
    end
    
    def config_path=(config_path)
      @config_path = config_path || File.join(app_dir, 'config.js')
    end
    
    def load_config
      @config = JSON.parse(File.read(config_path))
    end
    
    def build
    end
    
  end
end