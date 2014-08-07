require 'rake/testtask'
require './lib/gifs'
require './lib/videos'
require './lib/hacker_news'

namespace :publish do
  desc 'Publishes a gif'
  task :gif do
    puts "Publishing gif..."
    Gifs.new.run
    puts "done."
  end

  desc 'Publishes a video'
  task :video do
    puts "Publishing video..."
    Videos.new.run
    puts "done."
  end

  desc 'Publishes a piece of news'
  task :news do
    puts "Publishing news..."
    HackerNews.new.run
    puts "done."
  end
end

# Tests

Rake::TestTask.new do |t|
  t.libs = ["lib"]
  t.warning = false
  t.verbose = true
  t.test_files = FileList['spec/*_spec.rb']
end

task :default => [:test]
