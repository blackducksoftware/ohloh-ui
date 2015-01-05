require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:linux)
    @permissions = create(:permission, target: @project, remainder: false)
  end

  # show action
  test 'unlogged users should see permissions alert' do
    login_as nil
    get :show, id: @project
    assert_response :ok
    assert response.body.include?(I18n.t('permissions.must_log_in'))
    assert_tag tag: 'input', attributes: { disabled: 'disabled' }
  end

  test 'admins should not see permissions alert' do
    login_as accounts(:admin)
    get :show, id: @project
    assert_response :ok
    assert !response.body.include?('flash-msg')
    assert_no_tag tag: 'input', attributes: { disabled: 'disabled' }
  end

  test 'non-managers should see permissions alert' do
    login_as accounts(:user)
    get :show, id: @project
    assert_response :ok
    assert response.body.include?(I18n.t('permissions.not_manager'))
    assert_tag tag: 'input', attributes: { disabled: 'disabled' }
  end

  test 'managers pending approval should see permissions alert' do
    Manage.create(target: @project, account_id: accounts(:admin).id) # auto-approved
    Manage.create(target: @project, account_id: accounts(:user).id) # pending approval
    login_as accounts(:user)
    get :show, id: @project
    assert_response :ok
    assert response.body.include?(I18n.t('permissions.not_manager'))
    assert_tag tag: 'input', attributes: { disabled: 'disabled' }
  end

  test 'approved managers should not see permissions alert' do
    login_as accounts(:user)
    Manage.create(target: @project, account_id: accounts(:user).id, approved_by: accounts(:admin).id)
    get :show, id: @project
    assert_response :ok
    assert !response.body.include?('flash-msg')
    assert_no_tag tag: 'input', attributes: { disabled: 'disabled' }
  end

  test 'should gracefully handle non-existent projects' do
    login_as nil
    get :show, id: 'i_am_a_banana'
    assert_response :not_found
  end

  # update action
  test 'unlogged users should 401' do
    login_as nil
    put :update, id: @project, permission: { remainder: true }
    assert_response :unauthorized
  end

  test 'admins should be able to update the permissions' do
    login_as accounts(:admin)
    put :update, id: @project, permission: { remainder: true }
    @permissions.reload
    assert_response :ok
    assert_equal true, @permissions.remainder
  end

  test 'non-managers should 401' do
    login_as accounts(:user)
    put :update, id: @project, permission: { remainder: true }
    assert_response :unauthorized
  end

  test 'managers pending approval should 401' do
    Manage.create(target: @project, account_id: accounts(:admin).id) # auto-approved
    Manage.create(target: @project, account_id: accounts(:user).id) # pending approval
    login_as accounts(:user)
    put :update, id: @project, permission: { remainder: true }
    assert_response :unauthorized
  end

  test 'approved managers should be able to update the permissions' do
    login_as accounts(:user)
    Manage.create(target: @project, account_id: accounts(:user).id, approved_by: accounts(:admin).id)
    put :update, id: @project, permission: { remainder: true }
    @permissions.reload
    assert_response :ok
    assert_equal true, @permissions.remainder
  end

  test 'save failures should 422' do
    login_as accounts(:user)
    Manage.create(target: @project, account_id: accounts(:user).id, approved_by: accounts(:admin).id)
    Permission.any_instance.expects(:update).returns false
    put :update, id: @project, permission: { remainder: true }
    @permissions.reload
    assert_response :unprocessable_entity
    assert_equal false, @permissions.remainder
  end
end
