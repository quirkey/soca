require 'helper'

class TestSocaPusher < Test::Unit::TestCase

  context "macro plugin" do
    setup do
      @push = Soca::Pusher.new(@test_app_dir)
    end
   
    should "sanity" do
      @push.push!
    end


   end
end
