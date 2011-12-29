# For developers:
# Test the specification:
#   rake spec
# Build gem from source:
#   rake package
# Create documentation files (html):
#   rake rdoc

require 'rubygems/package_task'
require 'rdoc/task'
require 'rspec/core/rake_task'

# Build gem:
gem_spec = eval(File.read('rtp-connect.gemspec'))
Gem::PackageTask.new(gem_spec) do |pkg|
  pkg.gem_spec = gem_spec
  #pkg.need_tar = true
end

# RSpec 2:
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

# Build documentation:
RDoc::Task.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end