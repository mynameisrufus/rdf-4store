require 'spec'
require 'spec/rake/spectask'

task :default => [:spec]

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
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList[File.join("spec", "*.spec")]
    t.spec_opts = ["-fs", "-c", "-f", "h:report.html"]
    #t.spec_opts = ["-fs", "-c"]
    t.rcov = true
    #t.rcov_opts = ["-x", "/Library", "-x", "spec"]
  end
end

desc 'Run specs with backtrace'
task :tracespec => ["4store:init", "4store:start"] do
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList[File.join("spec", "*.spec")]
    t.rcov = false
    t.spec_opts = ["-bcfn"]
  end
end

desc "Build the rdf-4store-#{File.read('VERSION').chomp}.gem file"
task :build do
  sh "gem build .gemspec"
end

task :clean do
  rm_f "*~"
  rm_f "rdf-4store*.gem"
  rm_f "*/*~"
  rm_rf "report.html"
  rm_rf "coverage"
end
