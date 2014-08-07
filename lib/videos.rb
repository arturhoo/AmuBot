require_relative './base_reddit_publisher'

class Videos < BaseRedditPublisher
  def initialize(reddit_kit = RedditKit)
    @subreddit = 'videos'
    @min_score = 1500
    super
  end

  def run
    super
    links.each do |l|
      mark_link_as_visited l
      text = prepare_text(l)
      hipchat[room].send('Videos', text, message_format: 'html',
                                         color: 'purple')
      break
    end
  end

  def prepare_text(link)
    text = "<strong>Video:</strong> <a href='#{link.url}'>#{link.title}</a>"
    thumbnail_url = Videos.thumbnail(link)
    return text unless thumbnail_url
    text + "<br><a href='#{link.url}'><img src='#{thumbnail_url}'"\
           ' height=160px></a>'
  end

  def self.thumbnail(link)
    return unless link.media_embed && link.media_embed[:content]
    content = link.media_embed[:content]
    regex = /.+image=(.+hqdefault.jpg)&amp.+/
    encoded_url = regex.match(content).captures.first
    URI.decode(encoded_url)
  rescue
    nil
  end
end
