require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :test => :spec
task :default => :spec

namespace :doc do
  begin
    require 'yard'
  rescue LoadError
    # ignore
  else
    YARD::Rake::YardocTask.new do |task|
      task.files   = ["lib/**/*.rb", "-", "CHANGELOG.md", "LICENSE"]
      task.options = [
        "--no-private",
        "--protected",
        "--output-dir", "doc/yard",
        "--tag", "authenticated:Requires a user logged in",
        "--tag", "admin:Requires an admin user logged in",
        "--markup", "markdown",
      ]
    end
  end
end