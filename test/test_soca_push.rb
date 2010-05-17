require 'helper'

class TestSocaPush < Test::Unit::TestCase

  context "Soca::Push" do
    setup do
      @test_app_dir = File.expand_path(File.join(File.dirname(__FILE__), 'testapp')) + '/'
      @push = Soca::Push.new(@test_app_dir)
    end

    context "init" do
      should "init with directory path" do
        assert_equal @test_app_dir, @push.app_dir
      end

      should "load config.js into config" do
        assert @push.config
        assert @push.config.is_a?(Hash)
        assert @push.config['mapDirectories'].is_a?(Hash)
      end
    end

    context "build" do
      setup do
        @app_file = @push.build
      end

      should "return a hash" do
        assert @app_file.is_a?(Hash)
      end

      should "build Jimfile" do
        assert_match(/jQuery/, @app_file['_attachments']['js']['bundled.js'])
      end

      should "ignore files mapped to false or null" do
        assert !@app_file['Jimfile']
      end

      should "not include any . files" do
        assert !@app_file['.couchapprc']
      end

      should "map the directories to the correct paths in the JSON" do
        assert_match(/function/, @app_file['views']['recent']['map.js'])
        assert_match(/body/, @app_file['_attachments']['css']['app.css'])
      end
    end

    context "push_url" do
      should "construct push URL from id and couchapprc" do
        assert_equal 'http://admin:admin@localhost:5984/testapp/_design/testapp', @push.push_url
      end

      should "construct url for different envs" do
        assert_equal 'http://admin:admin@c.ixxr.net/testapp/_design/testapp', @push.push_url("production")
      end
    end

    context "push" do
      should "push the app to the push url" do

      end
    end

  end

end
