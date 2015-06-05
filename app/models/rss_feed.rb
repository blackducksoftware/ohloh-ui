require 'simple-rss'
require 'open-uri'

class RssFeed < ActiveRecord::Base
  has_many :rss_subscriptions
  has_many :projects, through: :rss_subscriptions
  has_many :rss_articles
  default_scope { order('last_fetch DESC') }
  validates :url, url_format: true, allow_blank: false
  filterable_by ['rss_feeds.url']

  def fetch(current_user)
    handle_fetch(url, current_user)
    self.last_fetch ||= Time.now.utc
    schedule_next_fetch
    save(validate: false)
  end

  def handle_fetch(url, current_user)
    parse(url, current_user)
    rescue Timeout::Error
      self.error = I18n.t('rss_feeds.index.timeout_error', url: url)
    rescue
      self.error = I18n.t('rss_feeds.index.error', url: url, message: $ERROR_INFO.message, trace: $ERROR_INFO.backtrace)
  end

  def schedule_next_fetch
    # If the fetch succeeds, another fetch will be scheduled 24 hours from now.
    # If the fetch fails, the wait until the next fetch will be doubled.
    if error
      self.next_fetch = Time.now.utc + (Time.now.utc - self.last_fetch) * 2
    else
      self.next_fetch = self.last_fetch + 1.day
    end
  end

  # Parses an RSS/Atom feed from a provided IO.
  # Returns an array of new articles.
  # If all articles are already known, an empty array is returned.
  def parse(io, current_user)
    rss = SimpleRSS.parse open(io)
    new_articles = rss.items.collect do |item|
      add_article(RssArticle.from_item(item))
    end.compact
    update_projects(current_user) unless new_articles.empty?
    new_articles
  end

  def update_projects(current_user)
    projects.each do |p|
      p.editor_account = current_user
      p.update_attribute(:updated_at, Time.now.utc)
    end
  end

  # Accepts a new rss_article if it is new, ignores it otherwise.
  # Returns the article if it was accepted, nil otherwise.
  def add_article(a)
    selected_articles = rss_articles.select { |x| x.guid.to_s == a.guid.to_s }
    rss_articles << a if selected_articles.empty?
  end
end
