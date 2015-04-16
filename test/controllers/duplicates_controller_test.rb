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

  describe 'create' do
    it 'should require a current user' do
      post :create, project_id: create(:project).to_param, duplicate: { good_project_id: create(:project).to_param }
      assert_response :unauthorized
    end

    it 'should create duplicate record' do
      good = create(:project)
      bad = create(:project)
      login_as create(:account)
      post :create, project_id: bad.to_param, duplicate: { good_project_id: good.to_param, comment: 'Cow says: Moo' }
      assert_response 302
      Duplicate.where(good_project_id: good.id, bad_project_id: bad.id).first.comment.must_equal 'Cow says: Moo'
    end

    it 'should create gracefully handle garbage good_project_id' do
      good = create(:project)
      bad = create(:project)
      login_as create(:account)
      post :create, project_id: bad.to_param, duplicate: { good_project_id: 'I_am_a_banana' }
      assert_response :not_found
    end

    it 'should render the new page if the duplicate fails to save' do
      project = create(:project)
      login_as create(:account)
      post :create, project_id: project.to_param, duplicate: { good_project_id: project.to_param }
      assert_response :unprocessable_entity
      response.body.must_match I18n.t('duplicates.fields.legend', name: project.name)
    end
  end
end
