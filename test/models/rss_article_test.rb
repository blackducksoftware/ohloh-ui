require 'test_helper'

class RssArticleTest < ActiveSupport::TestCase
  it 'should validate RSS Article' do
    article = build(:rss_article, guid: '')
    article.wont_be :valid?
    article.errors.messages[:guid].first.must_equal 'can\'t be blank'
  end

  it 'should validate and create a RSS Article' do
    article = create(:rss_article)
    article.must_be :valid?
  end

  it 'should test the method from item' do
    rss = SimpleRSS.parse File.read('test/data/files/news.rss')
    item = rss.items.first
    article = RssArticle.from_item(item)
    article.must_be :valid?
  end
end
