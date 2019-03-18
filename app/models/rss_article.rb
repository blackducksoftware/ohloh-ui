require 'digest/sha1'

class RssArticle < ActiveRecord::Base
  belongs_to :rss_feed
  validates :guid, presence: true
  validates :title, presence: true

  def absolute_link
    return link if link =~ URI::DEFAULT_PARSER.make_regexp

    uri = URI.parse(rss_feed.url)
    "#{uri.scheme}://#{uri.host}#{link}"
  end

  class << self
    def from_item(item)
      new(title: item[:title], link: item[:url], description: item[:summary], author: item[:author],
          time: set_time(item), guid: guid_from_item(item))
    end

    def set_time(item)
      time = item[:published] || Time.current
      time > Time.current ? Time.current : time
    end

    def guid_from_item(item)
      Digest::SHA1.hexdigest([item[:title], item[:url], item[:summary]].compact.join('|'))
    end

    def remove_duplicates(articles)
      articles.map(&:guid).uniq.map { |guid| articles.detect { |article| article.guid == guid } }
    end
  end
end
