# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name    = 'soca'
  s.version = File.read(File.expand_path("VERSION", File.dirname(__FILE__))).chomp

  s.authors            = ['Aaron Quint']
  s.date               = Date.today
  s.default_executable = 'soca'
  s.description        = 'soca is a different way of writing apps for CouchDB. The structure is up to you.'
  s.email              = 'aaron@quirkey.com'
  s.executables        = ['soca']
  s.homepage           = 'http://github.com/quirkey/soca'
  s.rubygems_version   = '1.3.7'
  s.summary            = 'Sammy on CouchApp'
  s.require_paths      = ['lib']

  s.files            = %w[.document Gemfile Gemfile.lock HISTORY LICENSE VERSION README.md Rakefile] + Dir.glob('{lib,test}/**/*')
  s.extra_rdoc_files = %w[LICENSE README.md]
  s.test_files       = Dir.glob('test/**/*.rb')

  s.add_dependency 'json'          , '~>1.4.6'
  s.add_dependency 'mime-types'    , '~>1.16'
  s.add_dependency 'typhoeus'      , '~>0.2.4'
  s.add_dependency 'thor'          , '~>0.14.0'
  s.add_dependency 'jim'           , '~>0.3.1'
  s.add_dependency 'compass'       , '~>0.10.5'
  s.add_dependency 'mustache'      , '~>0.11.2'
  s.add_dependency 'coffee-script' , '~> 2.1.2'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard', '>= 0'
  s.add_development_dependency 'shoulda', '>= 0'
end

