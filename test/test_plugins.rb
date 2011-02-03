require 'helper'

class TestSocaPusher < Test::Unit::TestCase

    context "macro plugin" do
        setup do
            @pusher = Soca::Pusher.new(@test_app_dir)
            @sammy = File.read("#{@test_app_dir}/js/vendor/sammy-0.5.4.js")
            @view = "#{@test_app_dir}/db/views/recent/"
        end

        should "replace !code macros with file contents" do
            @pusher.push!
            assert @pusher.document['views']['recent'].all?{|part| part[1].include?(@sammy)}
        end

        should "keep the original code" do
            @pusher.push!
            parts = ['map','reduce'].inject({}){|res,part| res[part] = File.read("#{@view}/#{part}.js").split("\n");res}
            parts.each do |part,lines|
                contain_lines(part,lines)
            end
        end
    end

    def contain_lines(part,lines)
      lines.delete('  // !code js/vendor/sammy-0.5.4.js')
      lines.all? { |line| @pusher.document['views']['recent'][part].include?(line)}
    end


end
