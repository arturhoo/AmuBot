require 'hipchat'
require 'redis'
require_relative './outside_of_business_hours_error'

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
    fail OutsideOfBusinessHoursError
  end

  def links
    all_links.select do |l|
      redis.get(link_identifier(l)).nil? && link_score(l) >= min_score
    end
  end

  def mark_link_as_visited(link)
    redis.set link_identifier(link), 'check'
  end

  private

  attr_accessor :room, :hipchat, :all_links, :redis, :min_score
end
