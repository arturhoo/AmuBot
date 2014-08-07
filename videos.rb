require 'hipchat'
require 'redis'
require 'redditkit'

$room = ENV['ROOM']
$hipchat_api_token = ENV['HIPCHAT_TOKEN']

class Videos
  def self.run
    hipchat = HipChat::Client.new($hipchat_api_token, api_version: 'v2')
    if ENV['REDISTOGO_URL']
      redis = Redis.new(url: ENV['REDISTOGO_URL'])
    else
      redis = Redis.new
    end
    links = RedditKit.links('videos', category: 'hot')

    links.each do |l|
      if redis.get(l.id).nil? && l.score >= 1500 && !l.is_self?
        redis.set l.id, 'check'

        text = "<strong>Video:</strong> <a href='#{l.url}'>#{l.title}</a>"

        begin
          thumbnail_url = thumbnail(l)
          text += "<br><a href='#{l.url}'><img src='#{thumbnail_url}' "\
                  'height=160px></a>'
        rescue
        end
        hipchat[$room].send('Videos', text, message_format: 'html',
                            color: 'purple')
        break
      end
    end
  end

  def self.thumbnail(link)
    return unless link.media_embed && link.media_embed[:content]
    content = link.media_embed[:content]
    regex = /.+image=(.+hqdefault.jpg)&amp.+/
    encoded_url = regex.match(content).captures.first
    URI.decode(encoded_url)
  end
end
