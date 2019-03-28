require 'test_helper'

class RssFeedTest < ActiveSupport::TestCase
  before { Feedjira.logger.stubs(:warn) }

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
    rss_feed = create(:rss_feed, url: 'http://www.vcrlocalhost.org/feed.rss')
    VCR.use_cassette('RssFeed') do
      assert_difference 'rss_feed.rss_articles.count' do
        rss_feed.fetch
      end
    end
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
    VCR.use_cassette('RssFeed') do
      before = Time.current - 4.hours
      rss_feed = create(:rss_feed)
      project = create(:project)
      project.update_attributes(updated_at: before)
      project.reload.updated_at.to_i.must_equal before.to_i
      create(:rss_subscription, rss_feed: rss_feed, project: project)
      rss_feed.url = 'http://www.vcrlocalhost.org/feed.rss'
      rss_feed.fetch
      project.reload.updated_at.wont_equal before
    end
  end

  it 'should create new rss_articles when fetch happens' do
    VCR.use_cassette('RssFeed') do
      before = Time.current - 4.hours
      rss_feed = create(:rss_feed)
      project = create(:project)
      project.update_attributes(updated_at: before)
      project.reload.updated_at.to_i.must_equal before.to_i
      create(:rss_subscription, rss_feed: rss_feed, project: project)
      rss_feed.url = 'http://www.vcrlocalhost.org/feed.rss'
      rss_feed.rss_articles.must_equal []
      rss_feed.fetch
      rss_feed.rss_articles.count.must_equal 1
      rss_feed.fetch
      rss_feed.rss_articles.count.must_equal 1
    end
  end

  it 'should honor encoding properly' do
    VCR.use_cassette('RssFeed', preserve_exact_body_bytes: true) do
      rss_feed = create(:rss_feed)
      rss_feed.url = 'http://www.vcrlocalhost.org/feed.rss'
      rss_feed.fetch
      rss_feed.rss_articles.first.title.must_equal 'It will display ÀāĎĠĦž'
    end
  end

  describe '.sync' do
    it 'should sync only the feeds which next_fetch time is less than or equal to current time' do
      VCR.use_cassette('RssFeed') do
        before = Time.current - 4.hours
        rss_feed = create(:rss_feed, url: 'http://www.vcrlocalhost.org/feed.rss', next_fetch: Time.current + 1.day)
        project = create(:project)
        project.update_attributes(updated_at: before)
        create(:rss_subscription, rss_feed: rss_feed, project: project)
        rss_feed.rss_articles.must_equal []
        project.reload.updated_at.to_i.must_equal before.to_i
        RssFeed.sync
        rss_feed.reload.rss_articles.must_equal []
        project.reload.updated_at.to_i.must_equal before.to_i

        rss_feed = create(:rss_feed, url: 'http://www.vcrlocalhost.org/feed.rss')
        project = create(:project)
        project.update_attributes(updated_at: before)
        create(:rss_subscription, rss_feed: rss_feed, project: project)
        rss_feed.rss_articles.must_equal []
        project.reload.updated_at.to_i.must_equal before.to_i
        RssFeed.sync
        rss_feed.reload.rss_articles.count.must_equal 1
        project.reload.updated_at.to_i.wont_equal before.to_i
      end
    end

    it 'should sync only subscribed feeds' do
      VCR.use_cassette('RssFeed') do
        before = Time.current - 4.hours
        rss_feed = create(:rss_feed, url: 'http://www.vcrlocalhost.org/feed.rss', next_fetch: Time.current - 1.day)
        project = create(:project)
        project.update_attributes(updated_at: before)
        create(:rss_subscription, rss_feed: rss_feed, project: project, deleted: true)
        rss_feed.rss_articles.must_equal []
        project.reload.updated_at.to_i.must_equal before.to_i
        RssFeed.sync
        rss_feed.reload.rss_articles.must_equal []
        project.reload.updated_at.to_i.must_equal before.to_i

        rss_feed = create(:rss_feed, url: 'http://www.vcrlocalhost.org/feed.rss', next_fetch: Time.current - 1.day)
        project = create(:project)
        project.update_attributes(updated_at: before)
        create(:rss_subscription, rss_feed: rss_feed, project: project, deleted: false)
        rss_feed.rss_articles.must_equal []
        project.reload.updated_at.to_i.must_equal before.to_i
        RssFeed.sync
        rss_feed.reload.rss_articles.count.must_equal 1
        project.reload.updated_at.to_i.wont_equal before.to_i
      end
    end
  end

  describe '#fetch' do
    it 'should remove duplicate new feeds before saving into rss_articles table' do
      VCR.use_cassette('RssFeedDuplicate', allow_playback_repeats: true) do
        rss_feed = create(:rss_feed, url: 'http://www.vcrlocalhost.org/duplicate-feeds.rss')
        create(:rss_subscription, rss_feed: rss_feed)
        rss_feed.rss_articles.must_equal []
        rss_feed.fetch
        rss_feed.rss_articles.count.must_equal 1
        rss_feed.rss_articles.delete_all
        articles = rss_feed.send(:new_rss_article_items).map { |item| RssArticle.from_item(item) }
        articles.count.must_equal 2
        RssArticle.remove_duplicates(articles).count.must_equal 1
      end
    end
  end
end
