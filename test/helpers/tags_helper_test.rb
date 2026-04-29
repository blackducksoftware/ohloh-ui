# frozen_string_literal: true

require 'test_helper'

class TagsHelperTest < ActionView::TestCase
  include TagsHelper
  include ERB::Util

  describe 'tag_icon_link' do
    it 'should return link when project is edit authorized' do
      project = create(:project)
      project.stubs(:edit_authorized?).returns(true)
      stubs(:t).with('.tags').returns('Tags')
      result = tag_icon_link(project)
      _(result).must_match project_tags_path(project)
    end

    it 'should return text without link when project is not edit authorized' do
      project = create(:project)
      project.stubs(:edit_authorized?).returns(false)
      stubs(:t).with('.tags').returns('Tags')
      result = tag_icon_link(project)
      _(result).wont_match '<a'
    end
  end

  describe 'tag_links' do
    it 'should return links for all tags' do
      result = tag_links(%w[ruby python])
      _(result).must_match 'ruby'
      _(result).must_match 'python'
      _(result).must_match 'tag'
    end

    it 'should limit to max_tags' do
      result = tag_links(%w[ruby python java], 2)
      _(result).must_match 'ruby'
      _(result).must_match 'python'
      _(result).wont_match 'java'
    end

    it 'should handle single tag' do
      result = tag_links(%w[ruby])
      _(result).must_match 'ruby'
    end
  end

  describe 'tags_left' do
    it 'should return reached maximum when count is zero' do
      _(tags_left(0)).must_equal I18n.t('tags.reached_maximum')
    end

    it 'should return over maximum when count is negative' do
      result = tags_left(-3)
      _(result).must_match '3'
    end

    it 'should return remaining count with plural tags' do
      result = tags_left(5)
      _(result).must_match '5'
      _(result).must_match 'tags'
    end

    it 'should return remaining count with singular tag' do
      result = tags_left(1)
      _(result).must_match '1'
      _(result).must_match 'tag'
    end
  end
end
