require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  fixtures :forums, :topics, :posts
  
  def setup
    @forum = forums(:rails)
  end

  test "valid forum" do
    assert @forum.valid?
    assert @forum.save
  end

  test "invalid forum without a name" do
    @forum.name = nil
    assert_not @forum.valid?
    assert_not @forum.save
  end

  test "invalid forum without a numerical position" do
    @forum.position = "foo bar"
    assert_not @forum.valid?
    assert_not @forum.save
  end

  test "forum topics count and posts count are zero by default" do
    forum = Forum.create(name: "Example Forum")
    assert_equal 0, forum.posts_count
    assert_equal 0, forum.topics_count
  end

  test "forum should have associated topic" do
    assert_equal [topics(:pdi),topics(:sticky),topics(:ponies),topics(:il8n)], @forum.topics.to_a
  end

  test "forum should have associated posts through topic" do
    assert_equal [posts(:pdi),posts(:pdi_reply),posts(:pdi_rebuttal), posts(:ponies),posts(:sticky), posts(:il8n)], @forum.posts
  end
end
