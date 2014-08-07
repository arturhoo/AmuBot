require './base_publisher'

class Gifs < BasePublisher
  def initialize
    super
    @subreddit = 'gifs'
    @min_score = 2500
  end

  def run
    super
    links.each do |l|
      next unless l.url[-4..-1] == '.gif'
      @redis.set l.id, 'check'
      text = "<strong>Gif:</strong> #{l.title}<br><img src=\"#{l.url}\">"
      @hipchat[@room].send('Gifs', text, message_format: 'html',
                           color: 'purple')
      break
    end
  end
end
