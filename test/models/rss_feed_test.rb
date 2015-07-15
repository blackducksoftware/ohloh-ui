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
    rss_feed.url = 'test/fixtures/files/news.rss'
    rss_feed.fetch(create(:admin))
  end

  it 'shouldn\'t parse the RSS and raise error' do
    rss_feed = create(:rss_feed, url: 'http://www.somedomain.com')
    rss_feed.fetch(create(:admin))
    rss_feed.errors.wont_be_nil
  end

  it 'should not allow blank urls' do
    rss_feed = build(:rss_feed, url: '')
    rss_feed.wont_be :valid?
    rss_feed.errors.messages[:url].first.must_equal 'Invalid URL Format'
  end
end
