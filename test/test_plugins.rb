require 'helper'

class TestSocaPusher < Test::Unit::TestCase

  context "macro plugin" do
    setup do
      @pusher = Soca::Pusher.new(@test_app_dir)

      @sammy = File.read("#{@test_app_dir}/js/vendor/sammy-0.5.4.js")
      @source = File.read("#{@test_app_dir}/db/views/recent/map.js")
    end

    should "replace !code macros with file contents" do
        @pusher.push!
        assert @pusher.document['views']['recent']['map'].include?(@sammy)
    end

    should "keeps the original code" do
       @pusher.push!
       lines = @source.split("\n")
       lines.delete('  // !code js/vendor/sammy-0.5.4.js')
       lines.each do |line|
           assert @pusher.document['views']['recent']['map'].include?(line)
       end
    end

  end
end
