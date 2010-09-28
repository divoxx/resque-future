require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "resque-future"
    gem.summary     = "Resque plugin that allows querying future jobs for it's result"
    gem.description = <<-DESC
Resque plugin that allows querying future jobs for it's result, for example:

  job = Resque.enqueue_future(MixerWorker, "yeah")
  # store job.uuid somewhere
  
  # Later on
  job = Resque.get_future_job(uuid)
  job.ready?
  job.result
  job.finished_at
    DESC
    gem.email       = "divoxx@gmail.com"
    gem.homepage    = "http://github.com/divoxx/resque-future"
    gem.authors     = ["Rodrigo Kochenburger"]
    gem.add_dependency "resque", ">= 1.10.0"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    gem.add_development_dependency "redis", ">= 2.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
