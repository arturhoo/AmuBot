require './gifs'
require './videos'

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
end
