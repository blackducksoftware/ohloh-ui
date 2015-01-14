require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  fixtures :forums, :topics, :posts
  def setup
    @forum = forums(:rails)
  end

  test 'valid forum' do
    assert @forum.valid?
    assert @forum.save
  end

  test 'invalid forum without a name' do
    @forum.name = nil
    assert_not @forum.valid?
    assert_not @forum.save
  end

  test 'invalid forum without a numerical position' do
    @forum.position = 'foo bar'
    assert_not @forum.valid?
    assert_not @forum.save
  end

  test 'forum topics count and posts count are zero by default' do
    forum = Forum.create(name: 'Example Forum')
    assert_equal 0, forum.posts_count
    assert_equal 0, forum.topics_count
  end

  test 'forum should have associated topic sorted by sticky and replied at desc' do
    assert_equal [topics(:pdi), topics(:sticky), topics(:il8n), topics(:ponies)], @forum.topics.to_a
  end

  test 'forum should have associated posts through topic ordered by created at desc' do
    assert_equal [posts(:il8n), posts(:ponies), posts(:pdi_rebuttal),
                  posts(:pdi_reply), posts(:pdi), posts(:sticky)], @forum.posts.to_a
  end

  test 'destroying a forum destroys its accompanying topics and posts' do
    @forum.destroy
    assert_equal @forum.topics.count, 0
    assert_equal @forum.posts.count, 0
  end
end
