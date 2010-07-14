require 'spec'
require 'spec/rake/spectask'

task :default => [:spec]

desc 'Run specs'
task :spec do
  Spec::Rake::SpecTask.new("spec") do |t|
    t.spec_files = FileList["spec/*.spec"]
    t.spec_opts = ["-fs", "-c", "-f", "h:report.html"]
    t.rcov = true
    #t.rcov_opts = ["-x", "/Library", "-x", "spec"]
  end
end

desc 'Run specs with backtrace'
task :tracespec do
  Spec::Rake::SpecTask.new("tracespec") do |t|
    t.spec_files = FileList["spec/*.spec"]
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
  rm_f "*/*~"
  rm_rf "report.html"
  rm_rf "coverage"
end
