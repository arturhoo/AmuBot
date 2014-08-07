require './base_hn_publisher'

class HackerNews < BaseHNPublisher
  def initialize
    super
    @min_score = 150
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
end
