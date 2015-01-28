require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  before { create_must_and_wont_aliases(Forum) }
  let(:forum) { forums(:rails) }

  it 'valid forum' do
    forum.must_be :valid?
    forum.must :save
  end

  it 'invalid forum without a name' do
    forum.name = nil
    forum.wont_be :valid?
    forum.wont :save
  end

  it 'invalid forum without a numerical position' do
    forum.position = 'foo bar'
    forum.wont_be :valid?
    forum.wont :save
  end

  it 'forum topics count and posts count are zero by default' do
    forum = Forum.create(name: 'Example Forum')
    forum.posts_count.must_equal 0
    forum.topics_count.must_equal 0
  end

  it 'forum should have associated topic sorted by sticky and replied at desc' do
    forum.topics.to_a.must_equal [topics(:pdi), topics(:sticky), topics(:il8n), topics(:ponies)]
  end

  it 'forum should have associated posts through topic ordered by created at desc' do
    forum.posts.to_a.must_equal [posts(:il8n), posts(:ponies), posts(:pdi_rebuttal),
                                 posts(:pdi_reply), posts(:pdi), posts(:sticky)]
  end

  it 'destroying a forum destroys its accompanying topics and posts' do
    forum.destroy
    forum.topics.count.must_equal 0
    forum.posts.count.must_equal 0
  end
end
