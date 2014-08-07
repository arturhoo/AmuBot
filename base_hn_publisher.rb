require 'hipchat'
require 'redis'
require 'redditkit'
require 'json'
require 'open-uri'

class BaseHNPublisher
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
    response = JSON.parse(open('http://api.ihackernews.com/page').read)
    all_links = response['items']
    all_links.select do |l|
      @redis.get(l['id']).nil? && l['points'] >= @min_score && !l['url'].empty?
    end
  end

  def mark_link_as_visited(link)
    @redis.set link['id'], 'check'
  end
end
