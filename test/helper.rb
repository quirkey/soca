require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'soca'

class Test::Unit::TestCase
  
  def setup
    @log = StringIO.new
    Soca.logger = Logger.new(@log)
    @test_app_dir = File.expand_path(File.join(File.dirname(__FILE__), 'testapp')) + '/'
  end
end
