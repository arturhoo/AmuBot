require 'json'
require 'open-uri'
require './base_publisher'

class HackerNews < BasePublisher
  def initialize
    @min_score = 150
    response = JSON.parse(open('http://api.ihackernews.com/page').read)
    @all_links = response['items']
    super
  end

  def run
    super
    links.each do |l|
      mark_link_as_visited l
      text = "<strong>News:</strong> <a href='#{l['url']}'>#{l['title']}</a>"
      @hipchat[@room].send('News', text, message_format: 'html',
                           color: 'purple')
      break
    end
  end

  def link_identifier(link)
    link['id']
  end

  def link_score(link)
    link['points']
  end
end
