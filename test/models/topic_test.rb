# encoding: utf-8

require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  before { create_must_and_wont_aliases(Topic) }
  let(:topic) { create(:topic) }

  it 'create an invalid topic without a title' do
    topic.title = nil
    topic.wont_be :valid?
    topic.errors[:title].must_equal ["can't be blank"]
    topic.wont :save
  end

  it 'create an invalid topic without a post body' do
    topic_without_a_post_body = build(:topic) { |topic| topic.posts.build(body: nil) }
    topic_without_a_post_body.wont_be :valid?
    topic_without_a_post_body.posts[0].errors[:body].must_equal ["can't be blank"]
    topic_without_a_post_body.wont :save
  end

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

  it 'a topic should have associated posts ordered by created at asc' do
    topic = create(:topic, :with_posts)
    topic.posts.to_a.must_equal topic.posts.sort_by(&:created_at)
  end

  describe 'recent' do
    let(:closed_topic) { create(:topic, closed: true) }

    it 'should return open topic' do
      Topic.recent.must_include topic
    end

    it 'should not return closed topic' do
      Topic.recent.wont_include closed_topic
    end

    it 'should return only 10 topics' do
      create_list(:topic, 11)
      Topic.recent.length.must_equal 10
    end
  end
end
