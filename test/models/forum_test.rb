# frozen_string_literal: true

require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  before { create_must_and_wont_aliases(Forum) }
  let(:forum) { create(:forum) }

  it 'valid forum' do
    forum.must_be :valid?
    forum.must :save
  end

  it 'invalid forum without a name' do
    forum.name = nil
    forum.wont_be :valid?
    forum.errors[:name].must_equal ["can't be blank"]
    forum.wont :save
  end

  it 'invalid forum without a numerical position' do
    forum.position = 'foo bar'
    forum.wont_be :valid?
    forum.wont :save
  end

  it 'invalid forum with a floating number' do
    forum.position = 1.2
    forum.wont_be :valid?
    forum.wont :save
  end

  it 'invalid forum with a number more than 9 digits' do
    forum.position = 9_987_654_321
    forum.wont_be :valid?
    forum.wont :save
  end

  it 'forum topics count and posts count are zero by default' do
    forum = Forum.create(name: 'Example Forum')
    forum.posts_count.must_equal 0
    forum.topics_count.must_equal 0
  end

  it 'forum should have associated topic sorted by sticky and updated at desc' do
    forum = create(:forum_with_topics)
    forum.topics.to_a.must_equal forum.topics.sort_by(&:updated_at).reverse
    forum.topics.to_a.must_equal forum.topics.sort_by(&:sticky).reverse
  end

  it 'forum should have associated posts ordered by updated_at at asc' do
    topic = create(:topic, :with_posts)
    forum = topic.forum
    forum.posts.must_equal forum.posts.sort_by(&:updated_at)
  end

  it 'destroying a forum destroys its accompanying topics and posts' do
    forum.destroy
    forum.topics.count.must_equal 0
    forum.posts.count.must_equal 0
  end
end
