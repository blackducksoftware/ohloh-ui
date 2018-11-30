require 'test_helper'

describe 'TagsController' do
  describe 'index' do
    it 'should return tag cloud if no tag names are specified' do
      project = create(:project)
      Tag.any_instance.stubs(:recalc_weight!)
      create(:tagging, tag: create(:tag, name: 'c', taggings_count: 1000), taggable: project)
      create(:tagging, tag: create(:tag, name: 'algol', taggings_count: 1), taggable: project)
      create(:tagging, tag: create(:tag, name: 'c++', taggings_count: 100), taggable: project)
      get :index
      assert_response :success
      assert_select 'a[href="/tags?names=c"]', 1
      assert_select 'a[href="/tags?names=algol"]', 0
      assert_select 'a[href="/tags?names=c%2B%2B"]', 1
      response.body.must_match 'c'
      response.body.wont_match 'agol'
      response.body.must_match 'c++'
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
      get :index, names: %w[color word]
      assert_response :success
      assert_select "#project_#{project1.id}", 1
      assert_select "#project_#{project2.id}", 0
      assert_select "#project_#{project3.id}", 1
      response.body.must_match 'Red'
      response.body.wont_match 'Apple'
      response.body.must_match 'Blue'
    end

    it 'should support old syntax structure' do
      get :index, name: 'php/ruby/web'
      assert_response :success
    end

    it 'should support old syntax structure with content' do
      project1 = create(:project, name: 'PHP')
      tag1 = create(:tag, name: 'web')
      tag2 = create(:tag, name: 'ruby')
      create(:tagging, tag: tag1, taggable: project1)
      create(:tagging, tag: tag2, taggable: project1)
      get :index, name: 'web/ruby'
      assert_response :success
      response.body.must_match 'web'
      response.body.must_match 'ruby'
    end
  end
end
