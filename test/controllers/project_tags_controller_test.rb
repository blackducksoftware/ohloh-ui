require 'test_helper'

describe 'ProjectTagsController' do
  describe 'index' do
    it 'should show the current projects tags and related projects' do
      project1 = create(:project, name: 'Red')
      project2 = create(:project, name: 'Apple')
      project3 = create(:project, name: 'Blue')
      tag = create(:tag, name: 'color')
      create(:tagging, tag: tag, taggable: project1)
      create(:tagging, tag: tag, taggable: project3)
      get :index, project_id: project1.to_param
      assert_response :success
      assert_select "#related_project_#{project1.to_param}", 0
      assert_select "#related_project_#{project2.to_param}", 0
      assert_select "#related_project_#{project3.to_param}", 1
      response.body.must_match 'color'
    end
  end
end
