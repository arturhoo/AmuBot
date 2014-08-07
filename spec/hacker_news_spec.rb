require_relative './test_helper'
require_relative '../lib/hacker_news'

describe HackerNews do

  let(:hn_json_double) do
    [
      {
        'url' => 'bbc.co.uk',
        'title' => 'bbc',
        'id' => 1,
        'points' => 250
      },
      {
        'url' => 'nytimes.com',
        'title' => 'nyt',
        'id' => 2,
        'points' => 350
      },
    ]
  end
  subject { HackerNews.new(hn_json_double) }

  describe 'API' do
    it 'responds to #run' do
      subject.must_respond_to :run
    end

    it 'responds to #link_identifier' do
      subject.must_respond_to :link_identifier
    end

    it 'responds to #link_score' do
      subject.must_respond_to :link_score
    end
  end

  describe '#run' do
    let(:hipchat_mock_room) { MiniTest::Mock.new }
    let(:hipchat_mock) { MiniTest::Mock.new }

    before do
      subject.send(:room=, 'Room')

      hipchat_mock_room.expect(:send, true) do |a1, a2, a3|
        a1 == 'News' && a2.class == String && a3.class == Hash
      end
      hipchat_mock.expect(:[], hipchat_mock_room, [String])

      subject.send(:hipchat=, hipchat_mock)
    end
    after { Redis.new.flushdb }

    it 'calls the hipchat client correctly' do
      subject.run
      hipchat_mock.verify
    end

    it 'sends the link to the room correctly' do
      subject.run
      hipchat_mock_room.verify
    end
  end

  describe '#link_identifier' do
    it 'returns the link id' do
      subject.link_identifier(hn_json_double.first).must_equal 1
    end
  end

  describe '#link_score' do
    it 'returns the link score' do
      subject.link_score(hn_json_double.first).must_equal 250
    end
  end
end
