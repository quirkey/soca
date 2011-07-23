require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'compass'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'soca'
require 'soca/plugins/compass'

class Test::Unit::TestCase

  def setup
    @log = StringIO.new
    Soca.logger = Logger.new(@log)
    @test_app_dir = File.expand_path(File.join(File.dirname(__FILE__), 'testapp')) + '/'
    @new_app_dir  = File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', 'newapp'))
    FileUtils.rm_rf(@new_app_dir) if File.directory?(@new_app_dir)
    FileUtils.mkdir_p(@new_app_dir)
  end

  # stolen from the thor specs
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
  alias :silence :capture

end
