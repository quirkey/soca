require 'helper'

class TestSocaPusher < Test::Unit::TestCase

  context "macro plugin" do
    setup do
      @pusher = Soca::Pusher.new(@test_app_dir)
    end

    should "replace !code macros with file contents" do
        @pusher.push!
        sammy = File.read("#{@test_app_dir}/js/vendor/sammy-0.5.4.js")
        assert @pusher.document['views']['recent']['map'].include?(sammy)
    end


  end
end
