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
      if redis.get(l.id).nil? && l.score >= 1000
        redis.set l.id, 'check'

        text = "<strong>Video:</strong> <a href='#{l.url}'>#{l.title}</a>"
        hipchat[$room].send('Videos', text, message_format: 'html',
                            color: 'purple')
        break
      end
    end
  end
end
