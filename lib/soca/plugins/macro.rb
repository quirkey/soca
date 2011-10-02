# see http://tinyurl.com/6ab5svl views in coucdb < 1.1.x
# does not allow you to require modules so we can use couchapp
# style macros instead
module Soca
  module Plugins
    class Macro < Soca::Plugin

      name 'macro'

      def run(options = {})
        @pusher.document['views'].each do |view,code|
          ['map','reduce'].each{|part| macro_expand_on(part,code) if code[part]}
        end
      end

      def macro_expand_on(part,code)
       code[part] = code[part].split("\n").inject(" ") do |res,line|
          if line =~ /\/\/ !code (.*)/
           res += "\n#{File.read($1)}\n"
          else
           res += "#{line}\n"
          end
        end.strip
      end

    end
  end
end
