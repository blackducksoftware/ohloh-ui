# encoding: utf-8
require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  fixtures :forums, :accounts, :posts, :topics

  def setup
    @topic = topics(:ponies)
  end

  test "create a valid topic" do
    assert @topic.valid?
    assert @topic.save
  end

  test "default value for hits should be zero" do
    assert @topic.valid?
    assert @topic.save
    assert_equal @topic.hits, 0
  end

  test "default value for sticky should be zero" do
    assert @topic.valid?
    assert @topic.save
    assert @topic.sticky, 0
  end

  test "default value for posts count should be zero" do
    topic = forums(:rails).topics.build(account_id: accounts(:user).id, title: "Rails Best Practices", hits: 12, sticky: 4, closed: false)
    assert topic.valid?
    assert topic.save
    assert topic.posts_count, 0
  end

  test "default value for closed should be false" do
    assert @topic.valid?
    assert @topic.save
    assert_not @topic.closed
  end

  test "a topic should be associated with an account" do
    assert_equal @topic.account, accounts(:user)
  end

  test "a topic should be associated with a forum" do
    assert_equal @topic.forum, forums(:rails)
  end

  test "a topic should have associated posts ordered by created at desc" do
    @topic = topics(:galactus)
   assert_equal [posts(:galactus),posts(:silver_surfer)], @topic.posts.to_a
  end

end