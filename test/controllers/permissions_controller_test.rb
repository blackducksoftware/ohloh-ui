require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:linux)
    @permissions = create(:permission, target: @project, remainder: false)
  end

  def set_protection_to_true
    put :update, id: @project, permission: { remainder: true }
    @permissions.reload
  end

  # show action
  it 'unlogged users should see permissions alert' do
    login_as nil
    get :show, id: @project
    must_respond_with :ok
    response.body.must_include(I18n.t('permissions.must_log_in'))
    must_select 'input[disabled="disabled"]'
  end

  it 'admins should not see permissions alert' do
    login_as create(:admin)
    get :show, id: @project
    must_respond_with :ok
    response.body.wont_include('flash-msg')
    must_select 'input[disabled="disabled"]', false
  end

  it 'non-managers should see permissions alert only when project permission is true' do
    login_as accounts(:user)
    set_protection_to_true
    get :show, id: @project
    must_respond_with :ok
    response.body.must_include(I18n.t('permissions.not_manager'))
    must_select 'input[disabled="disabled"]'
  end

  it 'managers pending approval should see permissions alert when project permission is true' do
    Manage.create(target: @project, account_id: create(:admin).id) # auto-approved
    Manage.create(target: @project, account_id: accounts(:user).id) # pending approval
    login_as accounts(:user)
    set_protection_to_true
    get :show, id: @project
    must_respond_with :ok
    response.body.must_include(I18n.t('permissions.not_manager'))
    must_select 'input[disabled="disabled"]'
  end

  it 'approved managers should not see permissions alert' do
    login_as accounts(:user)
    Manage.create(target: @project, account_id: accounts(:user).id, approved_by: create(:admin).id)
    get :show, id: @project
    must_respond_with :ok
    response.body.wont_include('flash-msg')
    must_select 'input[disabled="disabled"]', false
  end

  it 'should gracefully handle non-existent projects' do
    login_as nil
    get :show, id: 'i_am_a_banana'
    must_respond_with :not_found
  end

  # update action
  it 'unlogged users should 401' do
    login_as nil
    put :update, id: @project, permission: { remainder: true }
    @permissions.reload
    must_respond_with :unauthorized
  end

  it 'admins should be able to update the permissions' do
    login_as create(:admin)
    put :update, id: @project, permission: { remainder: true }
    @permissions.reload
    must_respond_with :ok
    @permissions.remainder.must_equal true
  end

  it 'non-managers should 401' do
    login_as accounts(:user)
    set_protection_to_true
    put :update, id: @project, permission: { remainder: true }
    must_respond_with :unauthorized
  end

  it 'managers pending approval should 401' do
    Manage.create(target: @project, account_id: create(:admin).id) # auto-approved
    Manage.create(target: @project, account_id: accounts(:user).id) # pending approval
    login_as accounts(:user)
    set_protection_to_true
    put :update, id: @project, permission: { remainder: true }
    must_respond_with :unauthorized
  end

  it 'approved managers should be able to update the permissions' do
    login_as accounts(:user)
    Manage.create(target: @project, account_id: accounts(:user).id, approved_by: create(:admin).id)
    put :update, id: @project, permission: { remainder: true }
    @permissions.reload
    must_respond_with :ok
    @permissions.remainder.must_equal true
  end

  it 'save failures should 422' do
    login_as accounts(:user)
    Manage.create(target: @project, account_id: accounts(:user).id, approved_by: create(:admin).id)
    Permission.any_instance.expects(:update).returns false
    put :update, id: @project, permission: { remainder: true }
    @permissions.reload
    must_respond_with :unprocessable_entity
    @permissions.remainder.must_equal false
  end
end
