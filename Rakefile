require 'bundler'
Bundler::GemHelper.install_tasks
require 'rake'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "acts_as_list"
    gem.summary     = %Q{Gem version of acts_as_list Rails plugin}
    gem.description = %Q{Gem version of acts_as_list Rails plugin}
    gem.email       = "victor.pereira@bigrails.com"
    gem.homepage    = "http://github.com/vpereira/acts_as_list"
    gem.authors     = ["Victor Pereira", "Ryan Bates", "Rails Core"]
    gem.add_dependency "activerecord", ">= 3.0.0"
    gem.add_development_dependency "yard"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc 'Default: run acts_as_list unit tests.'
task :default => :test

desc 'Test the acts_as_ordered_tree plugin.'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  t.options += ['--title', "acts_as_list #{version} Documentation"]
end

