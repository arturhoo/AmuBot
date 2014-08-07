require_relative './test_helper'
require_relative '../lib/gifs'

describe Gifs do

  reddit_kit_double = Class.new do
    def self.links(_arg1, _options = {})
      []
    end
  end
  subject { Gifs.new(reddit_kit_double) }

  describe 'API' do
    it 'responds to #run' do
      subject.must_respond_to :run
    end
  end

  describe '#run' do
    let(:link1) do
      OpenStruct.new(id: 1, score: 10, is_self?: true, url: 'a.gif')
    end
    let(:link2) do
      OpenStruct.new(id: 2, score: 10, is_self?: false, url: 'b.gif')
    end
    let(:hipchat_mock_room) { MiniTest::Mock.new }
    let(:hipchat_mock) { MiniTest::Mock.new }

    before do
      subject.send(:min_score=, 5)
      subject.send(:room=, 'Room')

      hipchat_mock_room.expect(:send, true) do |a1, a2, a3|
        a1 == 'Gifs' && a2.class == String && a3.class == Hash
      end
      hipchat_mock.expect(:[], hipchat_mock_room, [String])

      subject.send(:hipchat=, hipchat_mock)
    end
    after { Redis.new.flushdb }

    it 'calls the hipchat client correctly' do
      subject.stub :all_links, [link1, link2] do
        subject.run
        hipchat_mock.verify
      end
    end

    it 'sends the link to the room correctly' do
      subject.stub :all_links, [link1, link2] do
        subject.run
        hipchat_mock_room.verify
      end
    end
  end
end
