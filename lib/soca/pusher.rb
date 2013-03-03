module Soca
  class Pusher
    attr_accessor :app_dir, :env, :document, :config_path, :revision
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
      if File.readable?(config_path)
        @config = JSON.parse(File.read(config_path))
      else
        raise "Could not find config at '#{config_path}'. Run `soca init`"
      end
    end

    def load_couchapprc
      @config ||= {}
      @config['couchapprc'] = JSON.parse(File.read(File.join(app_dir, '.couchapprc')))
      run_hooks!(:after_load_couchapprc)
    end

    def build
      @document = {}
      run_hooks!(:before_build)
      logger.debug "building app JSON"
      Dir.glob(app_dir + '**/**') do |path|
        next if File.directory?(path)
        @document = map_file(path, @document)
      end
      run_hooks!(:after_build)
      @document
    end

    def json
      JSON.pretty_generate(build)
    end

    def db_url
      if env =~ /^https?\:\/\// # the env is actual a db_url
        env
      else
        env_config = config['couchapprc']['env'][env]
        raise "No such env: #{env}" unless env_config && env_config['db']
        env_config['db']
      end
    end

    def push_url
      raise "no app id specified in config" unless config['id']
      config['not_design'] ? "#{db_url}/#{config['id']}" : "#{db_url}/_design/#{config['id']}"
    end

    def app_url
      "#{push_url}/index.html"
    end

    def create_db!
      logger.debug "creating db: #{db_url}"
      put!(db_url)
    end

    def get_current_revision
      logger.debug "getting current revision"
      current = get!(push_url)
      if current
        current_json = JSON.parse(current)
        self.revision = current_json['_rev']
        logger.debug "current revision: #{revision}"
      end
    end

    def push!
      create_db!
      build
      run_hooks!(:before_push)
      get_current_revision
      document['_rev'] = revision if revision
      post_body = JSON.generate(document)
      logger.debug "pushing document to #{push_url}"
      put!(push_url, post_body)
      run_hooks!(:after_push)
    end

    def purge!
      get_current_revision
      url = push_url
      url += "?rev=#{revision}" if revision && revision.length > 0
      logger.debug "deleting document at #{url}"
      delete!(url)
    end

    def compact!
      logger.debug "compacting #{db_url}"
      post!("#{db_url}/_compact")
    end

    def logger
      Soca.logger
    end

    def run_hooks!(hook)
      run_hook_file!(hook)
      run_plugin_hooks!(hook)
    end

    def run_hook_file!(hook)
      hook_file_path = File.join(app_dir, 'hooks', "#{hook}.rb")
      if File.readable? hook_file_path
        logger.debug "running hook: #{hook} (#{hook_file_path})"
        Dir.chdir(app_dir) do
          instance_eval(File.read(hook_file_path))
        end
        logger.debug "finished hook: #{hook} (#{hook_file_path})"
      end
    end

    def run_plugin_hooks!(hook)
      plugins.each do |plugin_name, plugin|
        if plugin.respond_to?(hook)
          plugin.send(hook)
        end
      end
    end

    def plugins
      return @plugins if @plugins
      if config['plugins']
        @plugins = config['plugins'].map do |plugin_config|
          plugin_name, plugin_options = [plugin_config].flatten
          require "soca/plugins/#{plugin_name}"
          plugin_options ||= {}
          plugin_options.dup.each {|k, v| plugin_options[k.to_sym] = v }
          [plugin_name, Soca::Plugin.plugins[plugin_name].new(self, plugin_options)]
        end
      else
        @plugins = []
      end
      @plugins
    end

    private
    def map_file(path, hash)
      file_data = File.binread(path)
      base_path = path.gsub(app_dir, '')
      if map = mapped_directories.detect {|k,v| k =~ base_path }
        logger.debug "Matched #{path} against #{map.inspect}"
        if map[1]
          base_path = base_path.gsub(map[0], map[1])
        else
          return hash
        end
      end
      if base_path =~ /^_attachments/
        hash['_attachments'] ||= {}
        hash['_attachments'][base_path.gsub(/_attachments\//, '')] = make_attachment(path, file_data)
      elsif base_path == 'rewrites.js'
        hash['rewrites'] = JSON.parse(file_data)
      else
        parts = base_path.gsub(/^\//, '').gsub(/\.js$/, '').split('/')
        current_hash = hash
        while !parts.empty?
          part = parts.shift
          if parts.empty?
            if part =~ /.json$/
              current_hash[part.gsub(/.json$/, '')] = JSON.parse(file_data)
            else
              current_hash[part] = file_data
            end
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
        'data' => Base64.encode64(data).gsub(/[\s\n\r]*/m,'')
      }
    end

    def mapped_directories
      return @mapped_directories if @mapped_directories
      map = config['mapDirectories'].collect {|k,v| [/^#{k}/, v] }
      @mapped_directories = map
    end

    def put!(url, body = '')
      logger.debug "PUT #{url}"
      logger.debug "body: #{body[0..80]} ..."
      response = Typhoeus::Request.put(url, :body => body)
      if response.success? || response.code == 412
        logger.debug "Response: #{response.code} #{response.body[0..200]}"
      else
        logger.error "Response: #{response.code} #{response.body[0..200]}"
      end
      response
    end

    def get!(url)
      logger.debug "GET #{url}"
      response = Typhoeus::Request.get(url)
      logger.debug "Response: #{response.code} #{response.body[0..200]}"
      response.code == 200 ? response.body : nil
    end

    def post!(url, body = '')
      logger.debug "POST #{url}"
      logger.debug "body: #{body[0..80]} ..."
      response = Typhoeus::Request.post(url, :body => body, :headers => {'Content-type' => 'application/json'})
      logger.debug "Response: #{response.code} #{response.body[0..200]}"
      response
    end

    def delete!(url)
      logger.debug "DELETE #{url}"
      response = Typhoeus::Request.delete(url)
      logger.debug "Response: #{response.code} #{response.body[0..200]}"
      response.code == 200 ? response.body : nil
    end

  end
end
