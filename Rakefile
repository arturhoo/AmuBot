require './gifs'
require './videos'

namespace :publish do
  desc 'Publishes a gif'
  task :gif do
    puts "Publishing gif..."
    Gifs.run
    puts "done."
  end

  desc 'Publishes a video'
  task :video do
    puts "Publishing video..."
    Videos.run
    puts "done."
  end
end
