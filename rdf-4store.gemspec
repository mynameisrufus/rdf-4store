#!/usr/bin/env ruby -rubygems
require File.expand_path("../lib/rdf/four_store/version", __FILE__)
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = RDF::FourStore::VERSION
  gem.platform           = Gem::Platform::RUBY

  gem.name               = 'rdf-4store'
  gem.homepage           = 'http://github.com/fumi/rdf-4store'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = '4store adapter for RDF.rb.'
  gem.description        = 'RDF.rb plugin providing 4store storage adapter.'
  gem.rubyforge_project  = 'rdf'

  gem.authors            = ['Fumihiro Kato', 'Rufus Post']
  gem.email              = 'fumi@fumi.me'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README UNLICENSE) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.9.2'
  gem.requirements               = ['4store 1.1.4 or greater']
  gem.requirements               = ['raptor 2.0.8 or greater']
  gem.add_development_dependency 'rspec',          '>= 2.11.0'
  gem.add_development_dependency 'rdf-spec',       '>= 0.3.11'
  gem.add_development_dependency 'rake'
  gem.add_runtime_dependency     'rdf',            '>= 0.3.11.1'
  gem.add_runtime_dependency     'linkeddata',     '>= 0.3.5'
  gem.add_runtime_dependency     'sparql-client',  '>= 0.3.3'
  gem.add_runtime_dependency     'equivalent-xml', '>= 0.3.0'
  gem.post_install_message       = nil
end
