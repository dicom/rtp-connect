# encoding: UTF-8

require File.expand_path('../lib/rtp-connect/version', __FILE__)

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'rtp-connect'
  s.version = RTP::VERSION
  s.date = Time.now
  s.summary = "Library for handling RTPConnect files."
  s.require_paths = ['lib']
  s.author = "Christoffer Lervag"
  s.email = "chris.lervag@gmail.com"
  s.homepage = "https://github.com/dicom/rtp-connect"
  s.license = "GPLv3"
  s.description = "RTPConnect is a file format used in radiotherapy for export & import of treatment planning data."
  s.files = Dir["{lib}/**/*", "[A-Z]*"]
  s.rubyforge_project = 'rtp-connect'

  s.required_ruby_version = '>= 1.9.2'
  s.required_rubygems_version = '>= 1.8.6'

  s.add_development_dependency('bundler', '>= 1.0.0')
  s.add_development_dependency('dicom', '>= 0.9.3')
  s.add_development_dependency('rake', '>= 0.9.2.2')
  s.add_development_dependency('rspec', '>= 2.9.0')
  s.add_development_dependency('mocha', '>= 0.10.5')
end