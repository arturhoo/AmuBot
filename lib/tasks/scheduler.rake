task :publish_gifs => :environment do
  puts "Publishing gifs..."
  Gifs.run
  puts "done."
end
