# encoding: utf-8
require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  before { create_must_and_wont_aliases(Topic) }
  let(:admin) { create(:admin) }
  let(:topic) { topics(:ponies) }

  it 'create a valid topic' do
    topic.must_be :valid?
    topic.must :save
  end

  it 'default value for hits should be zero' do
    topic.must_be :valid?
    topic.must :save
    topic.hits.must_equal 0
  end

  it 'default value for sticky should be zero' do
    topic = create(:topic, account: create(:admin))
    topic.sticky.must_equal 0
  end

  it 'default value for closed should be false' do
    topic.must_be :valid?
    topic.must :save
    topic.wont_be :closed
  end

  it 'a topic should be associated with an account' do
    accounts(:user).must_equal topic.account
  end

  it 'a topic should be associated with a forum' do
    forums(:rails).must_equal topic.forum
  end

  it 'a topic should have associated posts ordered by created at desc' do
    topic = topics(:galactus)
    topic.posts.to_a.must_equal [posts(:galactus), posts(:silver_surfer)]
  end
end
