$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'lib/soca'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "soca"
    gem.version = Soca::VERSION
    gem.summary = %Q{Sammy on CouchApp}
    gem.description = %Q{soca is a different way of writing apps for couchdb. The structure is up to you.}
    gem.email = "aaron@quirkey.com"
    gem.homepage = "http://github.com/quirkey/soca"
    gem.authors = ["Aaron Quint"]
    gem.add_development_dependency "shoulda", ">= 0"
    gem.add_development_dependency "yard", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
