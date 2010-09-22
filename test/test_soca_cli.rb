require 'helper'

class TestSocaCLI < Test::Unit::TestCase

  context "Soca::CLI" do

    context "push" do
      setup do
        @response = Typhoeus::Response.new(:code => 201, :headers => "", :body => '{"ok":"true"}')
      end

      context "with default env" do
        should "push with http put" do
          Soca::Pusher.any_instance.expects(:put!).twice
          run_cli('push', '--appdir', @test_app_dir)
        end
      end

    end

    context "init" do
      setup do
        run_cli('init', '--appdir', @new_app_dir)
      end

      should "generate a config.js" do
        assert_file(/mapDirectories/, @new_app_dir, 'config.js')
      end

      should "generate a .couchapprc" do
        assert_file(/env/, @new_app_dir, '.couchapprc')
      end
    end

    context "generate" do
      setup do
        run_cli('generate', @new_app_dir)
      end

      should "generate a config.js" do
        assert_file(/mapDirectories/, @new_app_dir, 'config.js')
      end

      should "generate a .couchapprc" do
        assert_file(/env/, @new_app_dir, '.couchapprc')
      end

      should "generate a Jimfile" do
        assert_file(/sammy/, @new_app_dir, 'Jimfile')
      end

      should "generate a js directory" do
        assert_directory(@new_app_dir, 'js')
      end

      should "generate an index.html" do
        assert_file(/\<html/, @new_app_dir, 'index.html')
      end

      should "generate a css directory" do
        assert_directory(@new_app_dir, 'css')
      end

      should "generate a hooks directory" do
        assert_directory(@new_app_dir, 'hooks')
      end

      should "generate a db directory" do
        assert_directory(@new_app_dir, 'db', 'views')
      end
    end

    context "url" do
      should "output app url" do
        run_cli("url", "--appdir", @test_app_dir)
        assert_match(/http\:\/\//, @stdout)
      end
    end

    context "build" do
      should "output ruby hash" do
        run_cli("build", "--appdir", @test_app_dir)
        assert_match(/\{/si, @stdout) # needs better test
      end
    end

    context "json" do
      should "output json design doc" do
        run_cli("json", "--appdir", @test_app_dir)
        assert parsed = JSON.parse(@stdout)
        assert parsed['_attachments']
      end
    end
  end

  private
  def run_cli(*args)
    @stdout = capture(:stdout) do
      Soca::CLI.start(args)
    end
  end

  def assert_file_exists(*path)
    path = File.join(*path)
    assert File.readable?(path), "file at #{path} does not exist or is not readable"
  end

  def assert_directory(*path)
    path = File.join(*path)
    assert File.directory?(path), "file at #{path} does not exist or is not a directory"
  end

  def assert_file(match, *path)
    assert_file_exists(*path)
    path = File.join(*path)
    contents = File.read(path)
    assert_match(match, contents, "#{match} expected in content of file at #{path} but #{contents} was found")
  end

end
