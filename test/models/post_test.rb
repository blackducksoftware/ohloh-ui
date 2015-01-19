# encoding: utf-8
require 'test_helper'

class PostTest < ActiveSupport::TestCase
  before { create_must_and_wont_aliases(Post) }
  let(:post) { posts(:pdi) }

  it 'a post without a body should not be able to save' do
    post.body = nil
    post.wont_be :valid?
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

  it 'posts should have an associated topic' do
    topics(:pdi).posts.to_a.must_equal [posts(:pdi), posts(:pdi_reply), posts(:pdi_rebuttal)]
  end

  it 'a post should find its corresponding topic' do
    post.topic.must_equal topics(:pdi)
  end

  it 'gracefully handles weirdly encoded post bodies' do
    posts(:pdi_reply).body = "* oprava chyby 33731\n* \xFAprava  podle Revize B anglick\xE9ho dokumentu\n"
    posts(:pdi_reply).body.split("\n")
      .must_equal ['* oprava chyby 33731', '* �prava  podle Revize B anglick�ho dokumentu']
  end

  it 'strip tags method removes ' do
    post = Post.new(body: "<p>Bad Tags</b>\n")
    post.body.must_equal 'Bad Tags'
  end
end
