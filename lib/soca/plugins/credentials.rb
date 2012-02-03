module Soca
  module Plugins
    class Credentials < Soca::Plugin

      name 'credentials'

      # Credentials plugin
      # This plugin is run after the couchapprc is loaded,
      # it checks the db field in every environment,
      # searches for strings ending with '_CREDENTIALS' in the URI userinfo field,
      # passes the URI host to a method handling the requested credentials,
      # and replaces the userinfo with the username and password from the credentials method.
      #
      # When adding a new credentials method, please make sure the platform
      # specific requirements are met (e.g. external tools or gems)
      # and configure its platform availability in the credentials_supported? method

      def after_load_couchapprc
        config['couchapprc']['env'].each do |env, cfg|
          next unless cfg['db'] =~ /^(https?:\/\/)([^@]+_CREDENTIALS)@(.*)$/i
          scheme = $1
          userinfo = $2
          host = $3

          unless credentials_supported?(userinfo)
            Soca.logger.error "#{userinfo} are not supported on the #{RUBY_PLATFORM} platform"
            puts 'skip'
            next
          end

          (username, password) = send(userinfo.downcase, host)
          unless username and password
            Soca.logger.warn "#{userinfo} returned empty credentials for #{host}"
          else
            credentials = "#{username}:#{password}@"
            config['couchapprc']['env'][env]['db'] = "#{scheme}#{credentials}#{host}"
            Soca.logger.debug "Replacing #{userinfo} with #{credentials} in #{cfg['db']}"
          end
        end
      end

      private
      def credentials_supported?(type)
        Soca.logger.debug "Checking support for #{type} on #{RUBY_PLATFORM}"
        available_credentials = {
          'darwin' => %w[keychain_credentials],
          #'linux' => %w[]
        }
        supported_credentials = available_credentials.map { |os, list| list if RUBY_PLATFORM =~ /#{os}/i }
        supported_credentials.flatten.compact.include?(type.downcase)
      end

      # This methods retrieves the user credentials from the Mac OS X Keychain Services
      def keychain_credentials(host)
        begin
          require 'keychain'
        rescue LoadError
          warn "Please install the keychain_services gem, in order to retrieve user credentials from your keychain"
          return
        end

        Soca.logger.debug "Searching for #{host} in keychain"
        item = Keychain.items.find { |item| item if item.label == host }
        unless item
          # strip url-path from host url and search again
          (host, db) = host.split('/', 2)
          Soca.logger.debug "Searching for #{host} in keychain"
          item = Keychain.items.find { |item| item if item.label == host }
        end
        [item.account, item.password] if item
      end

    end
  end
end
