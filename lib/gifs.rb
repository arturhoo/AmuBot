require_relative './base_reddit_publisher'

class Gifs < BaseRedditPublisher
  def initialize(reddit_kit = RedditKit)
    @subreddit = 'gifs'
    @min_score = 1500
    super
  end

  def run
    super
    links.each do |l|
      next unless l.url[-4..-1] == '.gif'
      mark_link_as_visited l
      text = "<strong>Gif:</strong> #{l.title}<br><img src=\"#{l.url}\">"
      hipchat[room].send('Gifs', text, message_format: 'html',
                                       color: 'purple')
      break
    end
  end
end
