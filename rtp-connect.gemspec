# encoding: UTF-8

require File.expand_path('../lib/rtp-connect/version', __FILE__)

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'rtp-connect'
  s.version = RTP::VERSION
  s.date = Time.now
  s.summary = 'Library for handling RTPConnect files.'
  s.require_paths = ['lib']
  s.author = 'Christoffer Lervag'
  s.email = 'chris.lervag@gmail.com'
  s.homepage = 'https://github.com/dicom/rtp-connect'
  s.license = 'GPL-3.0'
  s.description = 'RTPConnect is a file format used in radiotherapy for export & import of treatment planning data.'
  s.files = Dir["{lib}/**/*", "[A-Z]*"]

  s.required_ruby_version = '>= 2.2'

  s.add_development_dependency('bundler', '~> 1.11')
  s.add_development_dependency('dicom', '~> 0.9', '>= 0.9.8')
  s.add_development_dependency('mocha', '~> 1.1')
  s.add_development_dependency('rake', '~> 12.3')
  s.add_development_dependency('redcarpet', '~> 3.4')
  s.add_development_dependency('rspec', '~> 3.7')
  s.add_development_dependency('yard', '~> 0.9', '>= 0.9.12')
end