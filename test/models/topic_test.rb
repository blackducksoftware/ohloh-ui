# encoding: utf-8
require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  before { create_must_and_wont_aliases(Topic) }
  let(:topic) { create(:topic) }

  it 'create a valid topic' do
    topic.must_be :valid?
    topic.must :save
  end

  it 'default value for hits should be zero' do
    topic.must_be :valid?
    topic.must :save
    topic.hits.must_equal 0
  end

  it 'default value for closed should be false' do
    topic.must_be :valid?
    topic.must :save
    topic.wont_be :closed
  end

  it 'a topic should have associated posts ordered by created at desc' do
    topic = create(:topic_with_posts)
    topic.posts.to_a.must_equal topic.posts.sort_by(&:created_at).reverse
  end
end
