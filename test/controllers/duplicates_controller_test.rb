require 'test_helper'

describe 'DuplicatesController' do
  describe 'new' do
    it 'should require a current user' do
      get :new, project_id: create(:project).to_param
      assert_response :redirect
      must_redirect_to new_session_path
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
      post :create, project_id: create(:project).to_param, duplicate: { good_project: create(:project).to_param }
      assert_response :redirect
      must_redirect_to new_session_path
    end

    it 'should create duplicate record' do
      good = create(:project)
      bad = create(:project)
      login_as create(:account)
      post :create, project_id: bad.to_param, duplicate: { good_project: good.to_param, comment: 'Cow says: Moo' }
      assert_response 302
      Duplicate.where(good_project_id: good.id, bad_project_id: bad.id).first.comment.must_equal 'Cow says: Moo'
    end

    it 'must display error mesesage for garbage good_project_id' do
      create(:project)
      bad = create(:project)
      login_as create(:account)

      post :create, project_id: bad.to_param, duplicate: { good_project: 'I_am_a_banana' }

      must_render_template 'new'
      assigns('duplicate').errors.messages[:good_project].must_be :present?
    end

    it 'should render the new page if the duplicate fails to save' do
      project = create(:project)
      login_as create(:account)
      post :create, project_id: project.to_param, duplicate: { good_project: project.to_param }
      assert_response :unprocessable_entity
      response.body.must_match I18n.t('duplicates.fields.legend', name: project.name)
    end
  end

  describe 'edit' do
    it 'should require a current user' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      get :edit, project_id: project.to_param, id: duplicate.id
      assert_response :redirect
      must_redirect_to new_session_path
    end

    it 'should require that the user be the reporter' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:account)
      get :edit, project_id: project.to_param, id: duplicate.id
      assert_response 302
    end

    it 'should allow the creator to edit duplicate' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account
      get :edit, project_id: project.to_param, id: duplicate.id
      assert_response :ok
    end

    it 'should allow admins to edit duplicates made by others' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:admin)
      get :edit, project_id: project.to_param, id: duplicate.id
      assert_response :ok
    end
  end

  describe 'update' do
    it 'should require a current user' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      post :update, project_id: project.to_param, id: duplicate.id,
                    duplicate: { good_project: duplicate.good_project_id, comment: 'Whatevs!' }
      assert_response :redirect
      must_redirect_to new_session_path
      duplicate.reload.comment.wont_equal 'Whatevs!'
    end

    it 'should require that the user be the reporter' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:account)
      post :update, project_id: project.to_param, id: duplicate.id,
                    duplicate: { good_project: duplicate.good_project_id, comment: 'Whatevs!' }
      assert_response 302
      duplicate.reload.comment.wont_equal 'Whatevs!'
    end

    it 'should allow the creator to edit duplicate' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account
      post :update, project_id: project.to_param, id: duplicate.id,
                    duplicate: { good_project: duplicate.good_project_id, comment: 'Whatevs!' }
      assert_response 302
      duplicate.reload.comment.must_equal 'Whatevs!'
    end

    it 'should allow admins to update duplicates made by others' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:admin)
      post :update, project_id: project.to_param, id: duplicate.id,
                    duplicate: { good_project: duplicate.good_project_id, comment: 'Whatevs!' }
      assert_response 302
      duplicate.reload.comment.must_equal 'Whatevs!'
    end

    it 'should gracefully handle validation errors' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account
      post :update, project_id: project.to_param, id: duplicate.id,
                    duplicate: { good_project: project.to_param, comment: 'Whatevs!' }
      assert_response :unprocessable_entity
      duplicate.reload.comment.wont_equal 'Whatevs!'
      response.body.must_match I18n.t('duplicates.fields.legend', name: project.name)
    end

    it 'must render error for blank good_project' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account

      post :update, project_id: project.to_param, id: duplicate.id,
                    duplicate: { good_project: '', comment: 'Whatevs!' }

      must_respond_with :unprocessable_entity
      assigns(:duplicate).errors.messages[:good_project].first.must_equal I18n.t('duplicates.no_valid_project')
    end
  end

  describe 'destroy' do
    it 'should require a current user' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      delete :destroy, project_id: project.to_param, id: duplicate.id
      Duplicate.where(id: duplicate.id).count.must_equal 1
    end

    it 'should require that the user be the reporter' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:account)
      delete :destroy, project_id: project.to_param, id: duplicate.id
      Duplicate.where(id: duplicate.id).count.must_equal 1
    end

    it 'should allow the creator to edit duplicate' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account
      delete :destroy, project_id: project.to_param, id: duplicate.id
      Duplicate.where(id: duplicate.id).count.must_equal 0
    end

    it 'should allow admins to update duplicates made by others' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:admin)
      delete :destroy, project_id: project.to_param, id: duplicate.id
      Duplicate.where(id: duplicate.id).count.must_equal 0
    end

    it 'should gracefully handle destroy errors' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account
      Duplicate.any_instance.expects(:destroy).returns false
      delete :destroy, project_id: project.to_param, id: duplicate.id
      Duplicate.where(id: duplicate.id).count.must_equal 1
    end
  end
end
