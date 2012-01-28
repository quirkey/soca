require 'helper'

class TestCredentialsPlugin < Test::Unit::TestCase
  def app_path(relative='')
    File.expand_path(@test_app_dir + '/' + relative)
  end

  context 'credentials plugin' do
    setup do
      @pusher = Soca::Pusher.new(app_path)
      @plugin = Soca::Plugins::Credentials.new(@pusher)
    end

    if RUBY_PLATFORM =~ /darwin/i
      require 'keychain'
      context 'given keychain credentials' do
        should 'check for platform availability' do
          @plugin.expects(:credentials_supported?).
            with('KEYCHAIN_CREDENTIALS').
            returns(true)
          @plugin.after_load_couchapprc
        end

        # Note this test requires you have
        # an application password item
        # in your keychain with the
        # name localhost:5894/testapp
        # username admin
        # password admin
        should 'return username and password for host from keychain' do
          @plugin.expects(:keychain_credentials).
            with('localhost:5984/testapp').
            returns(%w[admin admin])
          @plugin.after_load_couchapprc
        end
      end
    end

  end
end
