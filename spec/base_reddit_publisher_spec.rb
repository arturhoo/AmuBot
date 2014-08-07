require_relative './test_helper'
require_relative '../lib/base_reddit_publisher'

describe BaseRedditPublisher do

  reddit_kit = Class.new do
    def self.links(arg1, options={})
      []
    end
  end
  subject { BaseRedditPublisher.new(reddit_kit) }

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
    before do
      subject.send(:min_score=, 5)
      @link1 = OpenStruct.new(id: 1, score: 10, is_self?: true)
      @link2 = OpenStruct.new(id: 2, score: 10, is_self?: false)
    end

    describe 'with only one not being self' do
      it 'returns only the non-self link' do
        subject.stub :all_links, [@link1, @link2] do
          subject.run.must_equal [@link2]
        end
      end
    end
  end

  describe '#link_identifier' do
    before {@link = OpenStruct.new(full_name: 'Full Name') }

    it 'returns the link full name' do
      subject.link_identifier(@link).must_equal 'Full Name'
    end
  end

  describe '#link_score' do
    before {@link = OpenStruct.new(score: 10) }

    it 'returns the link score' do
      subject.link_score(@link).must_equal 10
    end
  end
end
