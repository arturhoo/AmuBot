require 'redditkit'
require_relative './base_publisher'

class BaseRedditPublisher < BasePublisher
  def initialize
    super
    @all_links = RedditKit.links(@subreddit, category: 'hot')
  end

  def run
    super
    @all_links.to_a.reject! { |l| l.is_self? }
  end

  def link_identifier(link)
    link.full_name
  end

  def link_score(link)
    link.score
  end
end
