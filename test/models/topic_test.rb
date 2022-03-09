# frozen_string_literal: true

require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  before { create_must_and_wont_aliases(Topic) }
  let(:topic) { create(:topic) }

  it 'create an invalid topic without a title' do
    topic.title = nil
    _(topic).wont_be :valid?
    _(topic.errors[:title]).must_equal ["can't be blank"]
    _(topic).wont_be :save
  end

  it 'create an invalid topic without a post body' do
    topic_without_a_post_body = build(:topic) { |topic| topic.posts.build(body: nil) }
    _(topic_without_a_post_body).wont_be :valid?
    _(topic_without_a_post_body.posts[0].errors[:body]).must_equal ["can't be blank"]
    _(topic_without_a_post_body).wont_be :save
  end

  it 'create a valid topic' do
    _(topic).must_be :valid?
    _(topic).must_be :save
  end

  it 'default value for hits should be zero' do
    _(topic).must_be :valid?
    _(topic).must_be :save
    _(topic.hits).must_equal 0
  end

  it 'default value for closed should be false' do
    _(topic).must_be :valid?
    _(topic).must_be :save
    _(topic).wont_be :closed
  end

  it 'a topic should have associated posts ordered by created at asc' do
    topic = create(:topic, :with_posts)
    _(topic.posts.to_a).must_equal topic.posts.sort_by(&:created_at)
  end

  describe 'recent' do
    let(:closed_topic) { create(:topic, closed: true) }

    it 'should return open topic' do
      _(Topic.recent).must_include topic
    end

    it 'should not return closed topic' do
      _(Topic.recent).wont_include closed_topic
    end

    it 'should return only 10 topics' do
      create_list(:topic, 11)
      _(Topic.recent.length).must_equal 10
    end
  end
end
