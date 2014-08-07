require_relative './test_helper'
require_relative '../lib/videos'

describe Videos do

  reddit_kit_double = Class.new do
    def self.links(_arg1, _options = {})
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
        a1 == 'Videos' && a2.class == String && a3.class == Hash
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

  let(:media_embed) do
    Class.new do
      def self.[](_arg1)
        "&lt;iframe class=\"embedly-embed\" src=\"//cdn.embedly.com/wid"\
        'gets/media.html?src=http%3A%2F%2Fwww.youtube.com%2Fembed%2F8Td'\
        'X7i2lHd4%3Ffeature%3Doembed&amp;url=http%3A%2F%2Fwww.youtube.c'\
        'om%2Fwatch%3Fv%3D8TdX7i2lHd4&amp;image=http%3A%2F%2Fi.ytimg.co'\
        'm%2Fvi%2F8TdX7i2lHd4%2Fhqdefault.jpg&amp;key=2aa3c4d5f3de4f5b9'\
        "120b660ad850dc9&amp;type=text%2Fhtml&amp;schema=youtube\" widt"\
        "h=\"600\" height=\"338\" scrolling=\"no\" frameborder=\"0\" al"\
        'lowfullscreen&gt;&lt;/iframe&gt;'
      end
    end
  end
  let(:link_with_media_embed) do
    OpenStruct.new(media_embed: media_embed, url: 'yt.com', title: 'Video 1')
  end

  describe '#prepare_text' do
    describe 'without a thumbnail url' do
      let(:link) { OpenStruct.new(url: 'yt.com', title: 'Video 1')}

      it 'formats the message correctly' do
        expected_text = "<strong>Video:</strong> <a href='yt.com'>Video 1</a>"
        subject.prepare_text(link).must_equal expected_text
      end
    end

    describe 'with a thumbnail url' do
      it 'formats the message correctly' do
        expected_text = "<strong>Video:</strong> <a href='yt.com'>Video 1</a>"\
                        "<br><a href='yt.com'><img src='http://i.ytimg.com/vi"\
                        "/8TdX7i2lHd4/hqdefault.jpg' height=160px></a>"
        subject.prepare_text(link_with_media_embed).must_equal expected_text
      end
    end
  end

  describe 'Videos::thumbnail' do
    subject { Videos }

    describe 'without a media embed' do
      let(:link) { OpenStruct.new }

      it 'returns nil' do
        subject.thumbnail(link).must_be_nil
      end
    end

    describe 'with a thumbnail embed' do
      describe 'but without content' do
        let(:link) { OpenStruct.new(media_embed: true) }

        it 'returns nil' do
          subject.thumbnail(link).must_be_nil
        end
      end

      describe 'with content' do
        it 'returns a decoded URI to the thumbnail' do
          expected_uri = 'http://i.ytimg.com/vi/8TdX7i2lHd4/hqdefault.jpg'
          subject.thumbnail(link_with_media_embed).must_equal expected_uri
        end
      end
    end
  end
end
