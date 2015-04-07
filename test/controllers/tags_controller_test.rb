require 'test_helper'

describe 'TagsController' do
  describe 'index' do
    it 'should return tag cloud if no tag names are specified' do
      project = create(:project)
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
  end
end
