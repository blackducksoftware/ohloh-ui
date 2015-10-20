require 'simple-rss'
require 'open-uri'

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

  private

  def execute_current_fetch
    create_rss_articles
  rescue Timeout::Error
    self.error = I18n.t('rss_feeds.index.timeout_error', url: url)
  rescue
    self.error = I18n.t('rss_feeds.index.error', url: url, message: $ERROR_INFO.message, trace: $ERROR_INFO.backtrace)
  end

  def schedule_next_fetch
    next_fetch_date = error ? (Time.current + (Time.current - last_fetch) * 2) : (last_fetch + 1.day)
    self.next_fetch = next_fetch_date
  end

  def create_rss_articles
    new_articles = new_rss_article_items.map { |item| RssArticle.from_item(item) }
    rss_articles << new_articles
    projects.update_all(updated_at: Time.current) unless new_articles.empty?
  end

  def new_rss_article_items
    rss = SimpleRSS.parse open(url)
    existing_rss_articles = rss_articles.pluck(:guid)

    rss.items.reject do |item|
      guid = RssArticle.set_guid(item)
      existing_rss_articles.include?(guid)
    end
  end
end
