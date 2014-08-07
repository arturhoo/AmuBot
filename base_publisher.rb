require 'hipchat'
require 'redis'
require 'redditkit'

class BasePublisher
  def initialize
    @room = ENV['ROOM']
    @hipchat = HipChat::Client.new(ENV['HIPCHAT_TOKEN'], api_version: 'v2')
    if ENV['REDISTOGO_URL']
      @redis = Redis.new(url: ENV['REDISTOGO_URL'])
    else
      @redis = Redis.new
    end
  end

  def run
    return if Time.now.utc.hour >= 11 && Time.now.utc.hour < 22
    abort 'Exiting. Running outside of business hours...'
  end

  def links
    all_links = RedditKit.links(@subreddit, category: 'hot')
    all_links.select do |l|
      @redis.get(l.id).nil? && l.score >= @min_score && !l.is_self?
    end
  end
end
