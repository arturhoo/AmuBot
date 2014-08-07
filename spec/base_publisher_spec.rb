require_relative './test_helper'
require_relative '../lib/base_publisher'

describe 'BasePublisher' do

  subject { BasePublisher.new }

  it 'responds to #run' do
    subject.must_respond_to :run
  end

  it 'responds to #links' do
    subject.must_respond_to :links
  end

  it 'responds to #mark_link_as_visited' do
    subject.must_respond_to :mark_link_as_visited
  end
end
