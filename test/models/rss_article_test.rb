# frozen_string_literal: true

require 'test_helper'

class RssArticleTest < ActiveSupport::TestCase
  it 'should validate RSS Article' do
    article = build(:rss_article, guid: '')
    _(article).wont_be :valid?
    _(article.errors.messages[:guid].first).must_equal 'can\'t be blank'
  end

  it 'should validate and create a RSS Article' do
    article = create(:rss_article)
    _(article).must_be :valid?
  end

  it 'should test the method from item' do
    rss = Feedjira.parse File.read('test/data/files/news.rss')
    item = rss.entries.first
    article = RssArticle.from_item(item)
    _(article).must_be :valid?
  end

  it 'should return absolute_link path' do
    article = create(:rss_article, link: '/about.html')
    article.rss_feed.update!(url: 'http://openhub.net')
    _(article.absolute_link).must_equal 'http://openhub.net/about.html'
  end
end
