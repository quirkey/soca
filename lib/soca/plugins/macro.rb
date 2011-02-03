
# see http://tinyurl.com/6ab5svl views in coucdb < 1.1.x does not allow require of modules therfor we need to use macors
module Soca
    module Plugins
        class Macro < Soca::Plugin

            name 'macro'

            def run(options = {})
                @pusher.document['views'].each do |view,code|
                    code['map'] = code['map'].split("\n").inject(" ") do |res,line|
                        if line =~ /\/\/ !code (.*)/ 
                            res += "\n#{File.read($1)}\n"
                        else
                            res += "#{line}\n"
                        end
                    end
                end
            end
        end
    end
end
