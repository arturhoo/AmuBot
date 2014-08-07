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
      before { ENV['REDISTOGO_URL'] = 'redis://127.0.0.1' }
      after { ENV.delete 'REDISTOGO_URL' }

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
end
