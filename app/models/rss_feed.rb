# frozen_string_literal: true

require 'feedjira'

class RssFeed < ActiveRecord::Base
  has_many :rss_subscriptions
  has_many :projects, through: :rss_subscriptions
  has_many :rss_articles

  validates :url, url_format: true, allow_blank: false
  filterable_by ['rss_feeds.url']

  def fetch
    execute_current_fetch
    self.last_fetch ||= Time.current
    schedule_next_fetch
    save(validate: false)
  end

  class << self
    def sync
      RssFeed.where(id: RssSubscription.not_deleted.select('rss_feed_id'))
             .where("(next_fetch IS NULL OR next_fetch <= NOW() AT TIME ZONE 'UTC')")
             .find_each do |feed|
               yield feed if block_given?
               feed.fetch
             end
    end
  end

  private

  def execute_current_fetch
    create_rss_articles
    self.last_fetch = Time.current
    self.error = nil
  rescue Timeout::Error
    self.error = I18n.t('rss_feeds.index.timeout_error', url: url)
  rescue StandardError
    self.error = I18n.t('rss_feeds.index.error', url: url, message: $ERROR_INFO.message, trace: $ERROR_INFO.backtrace)
  end

  def schedule_next_fetch
    next_fetch_date = error ? (Time.current + (Time.current - last_fetch) * 2) : (last_fetch + 1.day)
    self.next_fetch = next_fetch_date
  end

  def create_rss_articles
    new_articles = new_rss_article_items.map { |item| RssArticle.from_item(item) }
    rss_articles << RssArticle.remove_duplicates(new_articles)
    projects.update_all(updated_at: Time.current) unless new_articles.empty?
  end

  def new_rss_article_items
    rss = Feedjira::Feed.fetch_and_parse(url)
    existing_rss_articles = rss_articles.pluck(:guid)

    rss.sanitize_entries!.reject do |item|
      guid = RssArticle.guid_from_item(item)
      existing_rss_articles.include?(guid)
    end
  end
end
