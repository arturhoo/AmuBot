require_relative './test_helper'
require_relative '../lib/videos'

describe Videos do

  reddit_kit_double = Class.new do
    def self.links(arg1, options={})
      []
    end
  end
  subject { Videos.new(reddit_kit_double) }

  describe 'API' do
    it 'responds to #run' do
      subject.must_respond_to :run
    end

    it 'responds to #prepare_text' do
      subject.must_respond_to :prepare_text
    end
  end

  describe '#run' do
    let(:link1) do
      OpenStruct.new(id: 1, score: 10, is_self?: true, url: 'yt.com',
                     title: 'Video 1')
    end
    let(:link2) do
      OpenStruct.new(id: 2, score: 10, is_self?: false, url: 'yt.com',
                     title: 'Video 2')
    end
    let(:hipchat_mock_room) { MiniTest::Mock.new }
    let(:hipchat_mock) { MiniTest::Mock.new }

    before do
      subject.send(:min_score=, 5)
      subject.send(:room=, 'Room')

      hipchat_mock_room.expect(:send, true) do |a1, a2, a3|
        a1 == 'Videos' && String === a2 && Hash === a3
      end
      hipchat_mock.expect(:[], hipchat_mock_room, [String])

      subject.send(:hipchat=, hipchat_mock)
    end

    it 'calls the hipchat client correctly' do
      subject.stub :all_links, [link1, link2] do
        subject.run
        hipchat_mock.verify
        hipchat_mock_room.verify
      end
    end
  end
end
