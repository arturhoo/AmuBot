require_relative './test_helper'
require_relative '../lib/base_publisher'

describe BasePublisher do

  subject { BasePublisher.new }

  describe 'API' do
    it 'responds to #run' do
      subject.must_respond_to :run
    end

    it 'responds to #links' do
      subject.must_respond_to :links
    end

    it 'responds to #mark_link_as_visited' do
      subject.must_respond_to :mark_link_as_visited
    end

    describe 'when running inside heroku' do
      before do
        ENV['REDISTOGO_URL'] = ENV['REDISTOGO_URL'] || 'redis://127.0.0.1'
      end

      it 'still responds to its API' do
        subject.must_respond_to :run
        subject.must_respond_to :links
        subject.must_respond_to :mark_link_as_visited
      end
    end
  end

  describe '#run' do
    describe 'on business hours' do
      before { Timecop.freeze(Time.new(2014, 1, 1, 12, 0, 0)) }
      after { Timecop.return }

      it 'returns nil' do
        subject.run.must_be_nil
      end

      it 'is silent' do
        proc { subject.run }.must_be_silent
      end
    end

    describe 'outside business hours' do
      before { Timecop.freeze(Time.new(2014, 1, 1, 0, 0, 0)) }
      after { Timecop.return }

      it 'throws error' do
        proc { subject.run }.must_raise OutsideOfBusinessHoursError
      end
    end
  end

  describe '#links' do
    before do
      def subject.link_score(link)
        link.score
      end

      def subject.link_identifier(link)
        link.id
      end

      subject.send(:min_score=, 5)
    end

    describe 'with no links' do
      before do
        def subject.all_links
          []
        end
      end

      it 'returns and empty array' do
        subject.links.must_be_empty
      end
    end

    describe 'with two links, only one above the threshold' do
      let(:link1) { OpenStruct.new(id: 1, score: 10) }
      let(:link2) { OpenStruct.new(id: 2, score: 3) }

      before do
      end
      after { Redis.new.flushdb }

      it 'returns only the link with score above the threshold' do
        subject.stub :all_links, [link1, link2] do
          subject.links.must_equal [link1]
        end
      end
    end

    describe 'with two links, only one unpublished' do
      let(:link1) { OpenStruct.new(id: 1, score: 10) }
      let(:link2) { OpenStruct.new(id: 2, score: 10) }

      before do
        Redis.new.set(1, 'check')
      end
      after { Redis.new.flushdb }

      it 'returns only the unpublished link' do
        subject.stub :all_links, [link1, link2] do
          subject.links.must_equal [link2]
        end
      end
    end
  end

  describe '#mark_link_as_visited' do
    let(:link) { OpenStruct.new(id: 1) }

    before do
      def subject.link_identifier(link)
        link.id
      end
    end
    after { Redis.new.flushdb }

    it 'sets the link id on redis' do
      subject.mark_link_as_visited(link)
      subject.send(:redis).get(link.id).must_equal 'check'
    end
  end
end
