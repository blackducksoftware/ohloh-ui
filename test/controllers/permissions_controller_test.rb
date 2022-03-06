# frozen_string_literal: true

# NOTE: The organization permission tests are covered by permissions_integration_test.
require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  let(:account) { create(:account) }

  before do
    @project = create(:project)
    @permission = create(:permission, target: @project, remainder: true)
  end

  describe 'show' do
    describe 'project' do
      it 'unlogged users should see permissions alert' do
        login_as nil
        get :show, params: { id: @project }
        assert_response :ok
        _(response.body).must_include(I18n.t('permissions.must_log_in'))
        assert_select 'input[disabled="disabled"]'
      end

      it 'admins should not see permissions alert' do
        login_as admin
        get :show, params: { id: @project }
        assert_response :ok
        _(response.body).wont_include('flash-msg')
        assert_select 'input[disabled="disabled"]', false
      end

      it 'non-managers should see permissions alert' do
        login_as account
        get :show, params: { id: @project }
        assert_response :ok
        _(response.body).must_include(I18n.t('permissions.not_manager'))
        assert_select 'input[disabled="disabled"]'
      end

      it 'managers pending approval should see permissions alert' do
        Manage.create(target: @project, account_id: admin.id) # auto-approved
        Manage.create(target: @project, account_id: account.id) # pending approval
        login_as account
        get :show, params: { id: @project }
        assert_response :ok
        _(response.body).must_include(I18n.t('permissions.not_manager'))
        assert_select 'input[disabled="disabled"]'
      end

      it 'approved managers should not see permissions alert' do
        login_as account
        Manage.create(target: @project, account_id: account.id, approved_by: admin.id)
        get :show, params: { id: @project }
        assert_response :ok
        _(response.body).wont_include('flash-msg')
        assert_select 'input[disabled="disabled"]', false
      end

      it 'should gracefully handle non-existent projects' do
        login_as nil
        get :show, params: { id: 'i_am_a_banana' }
        assert_response :not_found
      end

      it 'must render projects/deleted when project is deleted' do
        account = create(:account)
        project = create(:project)
        login_as account
        project.update!(deleted: true, editor_account: account)

        get :show, params: { id: project.to_param }

        assert_template 'deleted'
      end
    end
  end

  describe 'update' do
    describe 'project' do
      it 'unlogged users should 401' do
        login_as nil
        put :update, params: { id: @project, permission: { remainder: true } }
        assert_response :redirect
        assert_redirected_to new_session_path
      end

      it 'admins should be able to update the permissions' do
        login_as admin
        put :update, params: { id: @project, permission: { remainder: true } }
        @permission.reload
        assert_response :ok
        _(@permission.remainder).must_equal true
      end

      it 'non-managers should 401' do
        login_as account
        put :update, params: { id: @project, permission: { remainder: true } }
        assert_response :unauthorized
      end

      it 'managers pending approval should 401' do
        Manage.create(target: @project, account_id: admin.id) # auto-approved
        Manage.create(target: @project, account_id: account.id) # pending approval
        login_as account
        put :update, params: { id: @project, permission: { remainder: true } }
        assert_response :unauthorized
      end

      it 'approved managers should be able to update the permissions' do
        login_as account
        Manage.create(target: @project, account_id: account.id, approved_by: admin.id)
        put :update, params: { id: @project, permission: { remainder: true } }
        @permission.reload
        assert_response :ok
        _(@permission.remainder).must_equal true
      end

      it 'save failures should 422' do
        login_as account
        Manage.create(target: @project, account_id: account.id, approved_by: admin.id)
        Permission.any_instance.expects(:update).returns false
        put :update, params: { id: @project, permission: { remainder: true } }
        @permission.reload
        assert_response :unprocessable_entity
        _(@permission.remainder).must_equal true
      end
    end
  end
end
