# frozen_string_literal: true

require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  describe 'index' do
    it 'should return tag cloud if no tag names are specified' do
      project = create(:project)
      Tag.any_instance.stubs(:recalc_weight!)
      create(:tagging, tag: create(:tag, name: 'c', taggings_count: 1000), taggable: project)
      create(:tagging, tag: create(:tag, name: 'algol', taggings_count: 1), taggable: project)
      create(:tagging, tag: create(:tag, name: 'c++', taggings_count: 100), taggable: project)
      get :index
      assert_response :success
      assert_select 'a[href="/tags?names=c"]' do |elements|
        assert_equal 1, elements.size
      end
      assert_select 'a[href="/tags?names=algol"]', false
      assert_select 'a[href="/tags?names=c%2B%2B"]' do |elements|
        assert_equal 1, elements.size
      end
      _(response.body).must_match 'c'
      _(response.body).wont_match 'agol'
      _(response.body).must_match 'c++'
    end

    it 'should return list of projects that match the specified tags' do
      project1 = create(:project, name: 'Red')
      project2 = create(:project, name: 'Apple')
      project3 = create(:project, name: 'Blue')
      tag1 = create(:tag, name: 'color')
      tag2 = create(:tag, name: 'word')
      create(:tagging, tag: tag1, taggable: project1)
      create(:tagging, tag: tag1, taggable: project3)
      create(:tagging, tag: tag2, taggable: project1)
      create(:tagging, tag: tag2, taggable: project2)
      create(:tagging, tag: tag2, taggable: project3)
      get :index, params: { names: %w[color word] }
      assert_response :success
      assert_select "#project_#{project1.id}", 1
      assert_select "#project_#{project2.id}", 0
      assert_select "#project_#{project3.id}", 1
      _(response.body).must_match 'Red'
      _(response.body).wont_match 'Apple'
      _(response.body).must_match 'Blue'
    end

    it 'should support old syntax structure' do
      get :index, params: { name: 'php/ruby/web' }
      assert_response :success
    end

    it 'should support old syntax structure with content' do
      project1 = create(:project, name: 'PHP')
      tag1 = create(:tag, name: 'web')
      tag2 = create(:tag, name: 'ruby')
      create(:tagging, tag: tag1, taggable: project1)
      create(:tagging, tag: tag2, taggable: project1)
      get :index, params: { name: 'web/ruby' }
      assert_response :success
      _(response.body).must_match 'web'
      _(response.body).must_match 'ruby'
    end
  end
end
