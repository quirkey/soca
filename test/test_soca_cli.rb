require 'helper'

class TestSocaCLI < Test::Unit::TestCase

  context "Soca::CLI" do

    context "push" do
      setup do
        @response = Typhoeus::Response.new(:code => 201, :headers => "", :body => '{"ok":"true"}')
      end
      
      should "push to default env" do
        Typhoeus::Request.expects(:put).twice.returns(@response)
        run_cli('push', '--appdir', @test_app_dir)
      end
    end
    
  end
  
  private
  def run_cli(*args)
    Soca::CLI.new(args).run
  end
  
end