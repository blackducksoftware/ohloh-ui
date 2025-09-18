# frozen_string_literal: true

require 'test_helper'

class DuplicatesControllerTest < ActionController::TestCase
  describe 'show' do
    it 'should show unauthorized message' do
      duplicate = create(:duplicate, bad_project: create(:project))
      login_as create(:account)
      get :show, params: { id: duplicate.id }

      assert_response :unauthorized
    end

    it 'should redirect for no session' do
      duplicate = create(:duplicate, bad_project: create(:project))
      get :show, params: { id: duplicate.id }

      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should load with an admin session' do
      duplicate = create(:duplicate, bad_project: create(:project))
      admin = create(:admin)
      login_as admin

      ProjectDecorator.any_instance.stubs(:icon).returns('')
      get :show, params: { id: duplicate.id }

      assert_response :success
      _(assigns(:duplicate)).must_equal duplicate
    end
  end

  describe 'resolve' do
    it 'should show unauthorized message' do
      good_project = create(:project)
      bad_project = create(:project)
      duplicate = create(:duplicate, good_project: good_project, bad_project: bad_project)

      login_as create(:account)
      post :resolve, params: { id: duplicate.id, keep_id: bad_project.id }

      assert_response :unauthorized
    end

    it 'should redirect for no session' do
      good_project = create(:project)
      bad_project = create(:project)
      duplicate = create(:duplicate, good_project: good_project, bad_project: bad_project)

      post :resolve, params: { id: duplicate.id, keep_id: bad_project.id }

      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should resolve duplicate with an admin session' do
      good_project = create(:project)
      bad_project = create(:project)
      duplicate = create(:duplicate, good_project: good_project, bad_project: bad_project)

      login_as create(:admin)

      post :resolve, params: { id: duplicate.id, keep_id: bad_project.id }

      assert_response :redirect
      assert_redirected_to admin_duplicates_path
      _(assigns(:duplicate).resolved?).must_equal true
      _(assigns(:duplicate).good_project).must_equal bad_project
      _(assigns(:duplicate).bad_project).must_equal good_project
    end
  end

  describe 'index' do
    it 'should 404 for normal user session' do
      login_as create(:account)
      get :index

      assert_response :unauthorized
    end

    it 'should redirect for no session' do
      get :index

      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should load with an admin session' do
      duplicate = create(:duplicate, bad_project: create(:project))
      admin = create(:admin)
      login_as admin

      get :index

      assert_response :success
      _(assigns(:resolved_duplicates)).must_equal []
      _(assigns(:unresolved_duplicates)).must_equal [duplicate]
    end
  end

  describe 'new' do
    it 'should require a current user' do
      get :new, params: { project_id: create(:project).to_param }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should succeed in normal conditions' do
      project = create(:project)
      login_as create(:account)
      get :new, params: { project_id: project.to_param }
      assert_response :ok
      _(response.body).must_match I18n.t('duplicates.fields.legend_html', name: project.name)
    end

    it 'should not allow setting a project to be a duplicate of something else already marked as good' do
      project = create(:project)
      create(:duplicate, good_project: project)
      login_as create(:account)
      get :new, params: { project_id: project.to_param }
      assert_response :found
    end

    it 'must render projects/deleted when project is deleted' do
      account = create(:account)
      project = create(:project)
      login_as account
      project.update!(deleted: true, editor_account: account)

      get :new, params: { project_id: project.to_param }

      assert_template 'deleted'
    end
  end

  describe 'create' do
    it 'should require a current user' do
      post :create,
           params: { project_id: create(:project).to_param, duplicate: { good_project_id: create(:project).to_param } }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should create duplicate record' do
      good = create(:project)
      bad = create(:project)
      login_as create(:account)
      post :create,
           params: { project_id: bad.to_param, duplicate: { good_project_id: good.to_param, comment: 'Cow says: Moo' } }
      assert_response :found
      _(Duplicate.where(good_project_id: good.id, bad_project_id: bad.id).first.comment).must_equal 'Cow says: Moo'
    end

    it 'must display error mesesage for garbage good_project_id' do
      create(:project)
      bad = create(:project)
      login_as create(:account)

      post :create, params: { project_id: bad.to_param, duplicate: { good_project_id: 'I_am_a_banana' } }

      assert_template 'new'
      _(assigns('duplicate').errors.messages[:good_project]).must_be :present?
    end

    it 'should render the new page if the duplicate fails to save' do
      project = create(:project)
      login_as create(:account)
      post :create, params: { project_id: project.to_param, duplicate: { good_project_id: project.to_param } }
      assert_response :unprocessable_entity
      _(response.body).must_match I18n.t('duplicates.fields.legend_html', name: project.name)
    end
  end

  describe 'edit' do
    it 'should require a current user' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      get :edit, params: { project_id: project.to_param, id: duplicate.id }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should require that the user be the reporter' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:account)
      get :edit, params: { project_id: project.to_param, id: duplicate.id }
      assert_response :found
    end

    it 'should allow the creator to edit duplicate' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account
      get :edit, params: { project_id: project.to_param, id: duplicate.id }
      assert_response :ok
    end

    it 'should allow admins to edit duplicates made by others' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:admin)
      get :edit, params: { project_id: project.to_param, id: duplicate.id }
      assert_response :ok
    end
  end

  describe 'update' do
    it 'should require a current user' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      post :update, params: { project_id: project.to_param, id: duplicate.id,
                              duplicate: { good_project_id: duplicate.good_project_id, comment: 'Whatevs!' } }
      assert_response :redirect
      assert_redirected_to new_session_path
      _(duplicate.reload.comment).wont_equal 'Whatevs!'
    end

    it 'should require that the user be the reporter' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:account)
      post :update, params: { project_id: project.to_param, id: duplicate.id,
                              duplicate: { good_project_id: duplicate.good_project_id, comment: 'Whatevs!' } }
      assert_response :found
      _(duplicate.reload.comment).wont_equal 'Whatevs!'
    end

    it 'should allow the creator to edit duplicate' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account
      post :update, params: { project_id: project.to_param, id: duplicate.id,
                              duplicate: { good_project_id: duplicate.good_project_id, comment: 'Whatevs!' } }
      assert_response :found
      _(duplicate.reload.comment).must_equal 'Whatevs!'
    end

    it 'should allow admins to update duplicates made by others' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:admin)
      post :update, params: { project_id: project.to_param, id: duplicate.id,
                              duplicate: { good_project_id: duplicate.good_project_id, comment: 'Whatevs!' } }
      assert_response :found
      _(duplicate.reload.comment).must_equal 'Whatevs!'
    end

    it 'should gracefully handle validation errors' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account
      post :update, params: { project_id: project.to_param, id: duplicate.id,
                              duplicate: { good_project_id: project.to_param, comment: 'Whatevs!' } }
      assert_response :unprocessable_entity
      _(duplicate.reload.comment).wont_equal 'Whatevs!'
      _(response.body).must_match I18n.t('duplicates.fields.legend_html', name: project.name)
    end

    it 'must render error for blank good_project' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account

      post :update, params: { project_id: project.to_param, id: duplicate.id,
                              duplicate: { good_project_id: '', comment: 'Whatevs!' } }

      assert_response :unprocessable_entity
      _(assigns(:duplicate).errors.messages[:good_project].first).must_equal I18n.t('duplicates.no_valid_project')
    end
  end

  describe 'destroy' do
    it 'should require a current user' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      delete :destroy, params: { project_id: project.to_param, id: duplicate.id }
      _(Duplicate.where(id: duplicate.id).count).must_equal 1
    end

    it 'should require that the user be the reporter' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:account)
      delete :destroy, params: { project_id: project.to_param, id: duplicate.id }
      _(Duplicate.where(id: duplicate.id).count).must_equal 1
    end

    it 'should allow the creator to edit duplicate' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account
      delete :destroy, params: { project_id: project.to_param, id: duplicate.id }
      _(Duplicate.where(id: duplicate.id).count).must_equal 0
    end

    it 'should allow admins to update duplicates made by others' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as create(:admin)
      delete :destroy, params: { project_id: project.to_param, id: duplicate.id }
      _(Duplicate.where(id: duplicate.id).count).must_equal 0
    end

    it 'should gracefully handle destroy errors' do
      project = create(:project)
      duplicate = create(:duplicate, bad_project: project)
      login_as duplicate.account
      Duplicate.any_instance.expects(:destroy).returns false
      delete :destroy, params: { project_id: project.to_param, id: duplicate.id }
      _(Duplicate.where(id: duplicate.id).count).must_equal 1
    end
  end
end
