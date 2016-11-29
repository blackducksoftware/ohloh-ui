# encoding: utf-8
require 'test_helper'

class PostTest < ActiveSupport::TestCase
  before { create_must_and_wont_aliases(Post) }
  let(:topic) { create(:topic) }
  let(:post) { create(:post) }

  it 'a post without a body should not be able to save' do
    post.body = nil
    post.wont_be :valid?
    post.errors[:body].must_equal ["can't be blank"]
    post.wont :save
  end

  it 'a post without an associated topic should not be able to save' do
    post.topic_id = nil
    post.wont_be :valid?
    post.wont :save
  end

  it 'a valid post should be able to save' do
    post.must_be :valid?
    post.must :save
  end

  it "should sort 'by_unanswered'" do
    Post.destroy_all
    unanswered_post = post
    create(:topic, :with_posts)
    Post.all.by_unanswered.must_equal [unanswered_post]
  end

  it 'posts should have an associated topic' do
    topic = create(:topic, :with_posts)
    topic.posts[0].topic.must_equal topic
    topic.posts[1].topic.must_equal topic
    topic.posts[2].topic.must_equal topic
  end

  it 'gracefully handles weirdly encoded post bodies' do
    post.body = "* oprava chyby 33731\n* \xFAprava  podle Revize B anglick\xE9ho dokumentu\n"
    post.body.split("\n")
        .must_equal ['* oprava chyby 33731', '* �prava  podle Revize B anglick�ho dokumentu']
  end

  it 'strip tags method removes ' do
    post.body = "<p>Bad Tags</b>\n"
    post.save
    post.reload
    post.body.must_equal 'Bad Tags'
  end

  describe 'destroy_with_empty_topic' do
    it 'must destroy the post' do
      post.destroy_with_empty_topic

      Post.find_by(id: post.id).must_be_nil
    end

    it 'must destroy topic when forum_id is present and no other posts' do
      topic = post.topic
      topic.posts.count.must_equal 1

      post.destroy_with_empty_topic

      Post.find_by(id: post.id).must_be_nil
      Topic.find_by(id: topic.id).must_be_nil
    end

    it 'wont destroy topic when it has no forum_id' do
      topic = post.topic
      topic.posts.count.must_equal 1
      topic.update!(forum_id: nil)

      post.destroy_with_empty_topic

      Post.find_by(id: post.id).must_be_nil
      Topic.find_by(id: topic.id).must_be :present?
    end

    it 'wont destroy topic when it has other posts' do
      topic = post.topic
      topic.posts.count.must_equal 1
      create(:post, topic: topic)

      post.destroy_with_empty_topic

      Post.find_by(id: post.id).must_be_nil
      Topic.find_by(id: topic.id).must_be :present?
    end
  end
end
