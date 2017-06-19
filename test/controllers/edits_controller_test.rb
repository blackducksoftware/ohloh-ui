require 'test_helper'

describe EditsController do
  describe 'project edits pages' do
    before do
      @project = create(:project)
      create(:enlistment, project: @project, ignore: 'Ignored!')
      create(:link, project: @project)
      create(:permission, target: @project, remainder: false)
      create(:project_license, project: @project)
      create(:rss_subscription, project: @project).update_attributes(deleted: true)
      create(:alias, project: @project)
    end

    # index action
    it 'index should not require a current user' do
      login_as nil
      get :index, project_id: @project.to_param
      must_respond_with :ok
    end

    it 'index should support query param' do
      login_as nil
      @project.editor_account = create(:admin)
      @project.update_attributes(description: 'Blah!')
      @project.editor_account = create(:admin)
      @project.update_attributes(description: 'Wat?')
      get :index, project_id: @project.to_param, query: 'blah'
      must_respond_with :ok
      must_select "#edit_#{PropertyEdit.where(target: @project, value: 'Blah!').first.id}", true
      must_select "#edit_#{PropertyEdit.where(target: @project, value: 'Wat?').first.id}", false
    end

    # update action
    it 'undo should require a logged in user' do
      login_as nil
      create_edit = CreateEdit.where(target: @project).first
      post :update, id: create_edit.id, undo: 'true'
      assert_response :redirect
      must_redirect_to new_session_path
      assert_equal false, @project.reload.deleted?
    end

    it 'undo of creation edit should delete the project' do
      login_as create(:admin)
      create_edit = CreateEdit.where(target: @project).first
      post :update, id: create_edit.id, undo: 'true'
      assert_response :success
      assert_equal true, @project.reload.deleted?
    end

    it 'undo gracefully handles undo/redo errors' do
      login_as create(:admin)
      Edit.any_instance.stubs(:undo!).raises(ActiveRecord::Rollback)
      post :update, id: CreateEdit.where(target: @project).first.id, undo: 'true'
      assert_response 406
    end

    it 'redo should require a logged in user' do
      login_as nil
      create_edit = CreateEdit.where(target: @project).first
      create_edit.undo! create(:admin)
      post :update, id: create_edit.id, undo: 'false'
      assert_response :redirect
      must_redirect_to new_session_path
      assert_equal true, @project.reload.deleted?
    end

    it 'redo of creation edit should delete the project' do
      create_edit = CreateEdit.where(target: @project).first
      login_as create_edit.account
      @project.destroy
      post :update, id: create_edit.id, undo: 'false'
      assert_equal false, @project.reload.deleted?
      assert_response :success
    end

    it 'redo gracefully handles undo/redo errors' do
      login_as create(:admin)
      create_edit = CreateEdit.where(target: @project).first
      create_edit.undo! create(:admin)
      Edit.any_instance.stubs(:redo!).raises(ActiveRecord::Rollback)
      post :update, id: create_edit.id, undo: 'false'
      assert_response 406
    end
  end

  describe 'organization edits pages' do
    before do
      project = create(:project)
      @organization = project.organization
      create(:alias, project: project)
      create(:enlistment, project: project)
      create(:link, project: project)
      create(:project_license, project: project)
    end

    # index action
    it 'index should not require a current user' do
      login_as nil
      get :index, organization_id: @organization.to_param
      must_respond_with :ok
    end

    it 'index should be rendered for logged in user' do
      login_as create(:account)
      get :index, organization_id: @organization.to_param
      must_respond_with :ok
    end

    it 'index should support query param' do
      login_as nil
      @organization.editor_account = create(:account)
      @organization.update_attributes(description: 'Blah!')
      @organization.editor_account = create(:account)
      @organization.update_attributes(description: 'Wat?')
      get :index, organization_id: @organization.to_param, query: 'blah'
      must_respond_with :ok
      must_select "#edit_#{PropertyEdit.where(target: @organization, value: 'Blah!').first.id}", true
      must_select "#edit_#{PropertyEdit.where(target: @organization, value: 'Wat?').first.id}", false
    end
  end

  describe 'account edits pages' do
    before do
      @project = create(:project)
      @account = @project.editor_account
    end

    # index action
    it 'index should not require a current user' do
      login_as nil
      get :index, account_id: @account.to_param
      must_respond_with :ok
    end

    it 'index should support query param' do
      login_as nil
      @project.editor_account = @account
      @project.update_attributes(description: 'Blah!')
      @project.update_attributes(name: 'Wat?')
      get :index, account_id: @account.to_param, query: 'blah'
      must_respond_with :ok
      must_select "#edit_#{PropertyEdit.where(target: @project, value: 'Blah!').first.id}", true
      must_select "#edit_#{PropertyEdit.where(target: @project, value: 'Wat?').first.id}", false
    end
  end

  describe 'license edits pages' do
    before do
      project_license = create(:project_license)
      @license = project_license.license
    end

    # index action
    it 'index should not require a current user' do
      login_as nil
      get :index, license_id: @license.to_param
      must_respond_with :ok
    end

    it 'index should show even when a regular user is logged in' do
      login_as create(:account)
      get :index, license_id: @license.to_param
      must_respond_with :ok
    end

    it 'index should support query param' do
      login_as nil
      @license.editor_account = create(:account)
      @license.update_attributes(name: 'Blah!')
      @license.editor_account = create(:account)
      @license.update_attributes(name: 'Wat?')
      get :index, license_id: @license.to_param, query: 'blah'
      must_respond_with :ok
      must_select "#edit_#{PropertyEdit.where(target: @license, value: 'Blah!').first.id}", true
      must_select "#edit_#{PropertyEdit.where(target: @license, value: 'Wat?').first.id}", false
    end

    it 'must work for deleted license' do
      @license.destroy

      get :index, license_id: @license.to_param

      must_respond_with :ok
    end
  end

  describe 'show' do
    describe '#Project Edit' do
      it 'should not require a current user' do
        project = create(:project)
        login_as nil
        xhr :get, :show, id: project.edits.first.id, project_id: project.to_param
        must_respond_with :ok
        must_render_template '_show'
      end
    end

    describe 'Organization Edit' do
      it 'should not require a current user' do
        organization = create(:project).organization
        login_as nil
        xhr :get, :show, id: organization.edits.first.id, organization_id: organization.to_param
        must_respond_with :ok
        must_render_template '_show'
      end
    end

    describe 'Account Edit' do
      it 'should not require a current user' do
        account = create(:project).editor_account
        login_as nil
        xhr :get, :show, id: account.edits.first.id, account_id: account.to_param
        must_respond_with :ok
        must_render_template '_show'
      end
    end

    describe 'License Edit' do
      it 'should not require a current user' do
        license = create(:project_license).license
        login_as nil
        xhr :get, :show, id: license.edits.first.id, license_id: license.to_param
        must_respond_with :ok
        must_render_template '_show'
      end
    end
  end
end
