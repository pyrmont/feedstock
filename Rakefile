require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  ENV["APP_ENV"] = "test"
  t.test_files = FileList["test/**/*_test.rb"]
end
desc "Run tests"

task default: :test
