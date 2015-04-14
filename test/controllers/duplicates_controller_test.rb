require 'test_helper'

describe 'DuplicatesController' do
  describe 'new' do
    it 'should require a current user' do
      get :new, project_id: create(:project).to_param
      assert_response :unauthorized
    end

    it 'should succeed in normal conditions' do
      project = create(:project)
      login_as create(:account)
      get :new, project_id: project.to_param
      assert_response :ok
      response.body.must_match I18n.t('duplicates.fields.legend', name: project.name)
    end

    it 'should not allow setting a project to be a duplicate of something else already marked as good' do
      project = create(:project)
      create(:duplicate, good_project: project)
      login_as create(:account)
      get :new, project_id: project.to_param
      assert_response 302
    end
  end
end
