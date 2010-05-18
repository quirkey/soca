module Soca
  class Push
    attr_accessor :app_dir, :env, :config_path
    attr_reader :config

    def initialize(app_dir, env = 'default', config_path = nil)
      self.env         = env
      self.app_dir     = File.expand_path(app_dir) + '/'
      self.config_path = config_path
      load_config
      load_couchapprc
    end

    def config_path=(config_path)
      @config_path = config_path || File.join(app_dir, 'config.js')
    end

    def load_config
      @config = JSON.parse(File.read(config_path))
    end

    def load_couchapprc
      @config ||= {}
      @config['couchapprc'] = JSON.parse(File.read(File.join(app_dir, '.couchapprc')))
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

    def db_url
      env_config = config['couchapprc']['env'][env]
      raise "No such env: #{env}" unless env_config && env_config['db']
      env_config['db']
    end

    def push_url
      raise "no app id specified in config" unless config['id']
      "#{db_url}/_design/#{config['id']}"
    end

    def create_db!
      put!(db_url)
    end

    def push!(env = 'default')
      post_body = JSON.generate(build)
      create_db!
      put!(push_url, post_body)
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
      if base_path =~ /^_attachments/
        hash['_attachments'] ||= {}
        hash['_attachments'][base_path.gsub(/_attachments\//, '')] = make_attachment(path, file_data)
      else
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
      end
      hash
    end

    def make_attachment(path, data)
      # mime type for path
      type = MIME::Types.type_for(path).first
      content_type = type ? type.content_type : 'text/plain'
      {
        'content_type' => content_type,
        'data' => Base64.encode64(data)
      }
    end

    def mapped_directories
      return @mapped_directories if @mapped_directories
      map = {}
      config['mapDirectories'].collect {|k,v| map[/^#{k}/] = v }
      @mapped_directories = map
    end

    def put!(url, body = '')
      response = Typhoeus::Request.put(url, :body => body)
      puts response.code.inspect
      puts response.body.inspect
      response
    end

  end
end
