# frozen_string_literal: true

require 'test_helper'

class BlogLinkHelperTest < ActionView::TestCase
  include BlogLinkHelper

  describe 'blog_link_to' do
    it 'should return proper blog link' do
      BLOG_LINKS.each do |k, v|
        link = "<a class='meta' href='https://community.blackduck.com/s/article/#{v}' target='_blank'>rest</a>"
               .html_safe
        _(blog_link_to(link: k, link_text: 'rest')).must_equal link
      end
    end
  end

  describe 'blog_url_for' do
    it 'should return proper blog link url when available in BLOG_LINKS' do
      BLOG_LINKS.each do |k, v|
        _(blog_url_for(k)).must_equal "https://community.blackduck.com/s/article/#{v}"
      end
    end

    it 'should return proper blog link url when not available in BLOG_LINKS' do
      _(blog_url_for('test')).must_equal 'https://community.blackduck.com/s/article/test'
    end
  end
end
