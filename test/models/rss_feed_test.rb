require 'test_helper'

class RssFeedTest < ActiveSupport::TestCase
  it 'should validate RSS feed' do
    rss_feed = build(:rss_feed, url: 'invalid_url')
    rss_feed.wont_be :valid?
    rss_feed.errors.messages[:url].first.must_equal 'Invalid URL Format'
  end

  it 'should validate and create a RSS feed' do
    rss_feed = create(:rss_feed)
    rss_feed.must_be :valid?
  end

  it 'should parse the RSS feed and return true' do
    rss_feed = create(:rss_feed)
    rss_feed.url = 'test/data/files/news.rss'
    rss_feed.fetch
  end

  it 'shouldn\'t parse the RSS and raise error' do
    rss_feed = create(:rss_feed, url: 'http://www.somedomain.com')
    rss_feed.fetch
    rss_feed.errors.wont_be_nil
  end

  it 'should not allow blank urls' do
    rss_feed = build(:rss_feed, url: '')
    rss_feed.wont_be :valid?
    rss_feed.errors.messages[:url].first.must_equal 'Invalid URL Format'
  end

  it 'should handle time out errors' do
    url = 'http://rss.roll/never_gonna_sync_you_up.rss'
    rss_feed = create(:rss_feed, url: url)
    rss_feed.stubs(:create_rss_articles).raises Timeout::Error.new
    rss_feed.fetch
    rss_feed.error.must_equal I18n.t('rss_feeds.index.timeout_error', url: url)
  end

  it 'should update any associated projects whenever a successful sync occurs' do
    before = Time.current - 4.hours
    rss_feed = create(:rss_feed)
    project = create(:project)
    project.update_attributes(updated_at: before)
    project.reload.updated_at.to_time.to_i.must_equal before.to_i
    create(:rss_subscription, rss_feed: rss_feed, project: project)
    rss_feed.url = 'test/data/files/news.rss'
    rss_feed.fetch
    project.reload.updated_at.to_time.wont_equal before
  end

  it 'should create new rss_articles when fetch happens' do
    before = Time.current - 4.hours
    rss_feed = create(:rss_feed)
    project = create(:project)
    project.update_attributes(updated_at: before)
    project.reload.updated_at.to_time.to_i.must_equal before.to_i
    create(:rss_subscription, rss_feed: rss_feed, project: project)
    rss_feed.url = 'test/data/files/news.rss'
    rss_feed.rss_articles.must_equal []
    rss_feed.fetch
    rss_feed.rss_articles.count.must_equal 20
    rss_feed.fetch
    rss_feed.rss_articles.count.must_equal 20
  end
end
