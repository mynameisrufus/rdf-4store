require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

namespace "4store" do
  kbname = "rdf4storetest"
  httpd_options = "-U -s -1 -p 10008"
  desc 'Init 4store'
  task :init => [:stop] do
    sh "4s-backend-setup #{kbname}"
  end

  desc 'Start 4store'
  task :start => [:stop] do
    sh "4s-backend #{kbname}"
    sh "4s-httpd #{httpd_options} #{kbname}"
  end

  desc 'Stop 4store'
  task :stop do
    sh "pkill -f '4s-backend #{kbname}'" if system("pgrep -f '4s-backend #{kbname}'")
    sh "pkill -f '4s-httpd #{httpd_options} #{kbname}'" if system("pgrep -f '4s-httpd #{httpd_options} #{kbname}'")
  end
end

desc 'Run specs'
task :spec => ["4store:init", "4store:start"] do
  RSpec::Core::RakeTask.new do |t|
    t.pattern = 'spec/**/*.spec'
    #t.rspec_opts = ["-fs", "-c", "-f", "h:report.html"]
    t.rspec_opts = ["-fs", "-c"]
    t.rcov = true
  end
end

desc 'Run specs with backtrace'
task :tracespec => ["4store:init", "4store:start"] do
  RSpec::Core::RakeTask.new do |t|
    t.pattern = 'spec/**/*.spec'
    t.rspec_opts = ["-bcfn"]
    t.rcov = false
  end
end

task :clean do
  rm_f "*~"
  rm_f "rdf-4store*.gem"
  rm_f "*/*~"
  rm_rf "report.html"
  rm_rf "coverage"
end
