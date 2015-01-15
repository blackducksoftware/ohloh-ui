# encoding: utf-8
require 'test_helper'

class PostTest < ActiveSupport::TestCase
  fixtures :posts, :topics, :forums, :accounts

  def setup
    @post = posts(:pdi)
  end

  test 'a post without a body should not be able to save' do
    @post.body = nil
    assert_not @post.valid?
    assert_not @post.save
  end

  test 'a post without an associated topic should not be able to save' do
    @post.topic_id = nil
    assert_not @post.valid?
    assert_not @post.save
  end

  test 'a valid post should be able to save' do
    assert @post.valid?
    assert @post.save
  end

  test 'posts should have an associated topic' do
    assert_equal [posts(:pdi), posts(:pdi_reply), posts(:pdi_rebuttal)], topics(:pdi).posts.to_a
  end

  test 'a post should find its corresponding topic' do
    assert_equal topics(:pdi), @post.topic
  end

  test 'gracefully handles weirdly encoded post bodies' do
    posts(:pdi_reply).body = "* oprava chyby 33731\n* \xFAprava  podle Revize B anglick\xE9ho dokumentu\n"
    assert_equal ['* oprava chyby 33731', '* �prava  podle Revize B anglick�ho dokumentu'],
                 posts(:pdi_reply).body.split("\n")
  end

  test 'strip tags method removes ' do
    post = Post.new(body: "<p>Bad Tags</b>\n")
    assert_equal 'Bad Tags', post.body
  end
end
