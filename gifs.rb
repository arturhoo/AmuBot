require 'hipchat'
require 'redis'
require 'redditkit'

$room = ENV['ROOM']
$hipchat_api_token = ENV['HIPCHAT_TOKEN']

class Gifs
  def self.run
    hipchat = HipChat::Client.new($hipchat_api_token, api_version: 'v2')
    if ENV['REDISTOGO_URL']
      redis = Redis.new(url: ENV['REDISTOGO_URL'])
    else
      redis = Redis.new
    end
    links = RedditKit.links('gifs', category: 'hot')

    links.each do |l|
      if redis.get(l.id).nil? && l.score >= 1500 && l.url[-4..-1] == '.gif' &&
         !l.is_self?
        redis.set l.id, 'check'

        text = "<strong>Gif:</strong> #{l.title}<br><img src=\"#{l.url}\">"
        hipchat[$room].send('Gifs', text, message_format: 'html',
                            color: 'purple')
        break
      end
    end
  end
end
