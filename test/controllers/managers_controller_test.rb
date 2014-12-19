require 'test_helper'

class ManagersControllerTest < ActionController::TestCase
  fixtures :accounts, :projects, :organizations

  def test_index_of_project_for_manager
    login_as accounts(:admin)
    setup_admin_user_umlaut
    get :index, project_id: projects(:linux).to_param
    assert_response :success
    assert @response.body =~ /Pending/i
  end

  def test_index_for_i_manage_this_project_button_for_admin
    login_as accounts(:admin)
    get :index, project_id: projects(:linux).to_param
    assert_response :success
    assert_tag tag: 'a', attributes: { class: 'btn btn-primary' }
    assert_select '.col-md-4 a.btn.btn-primary', text: 'I manage this project on Open Hub'
  end

  def test_index_for_i_manage_this_project_button_for_admin_when_admin_is_manager
    login_as accounts(:admin)
    a = projects(:linux)
    a.managers << accounts(:admin)
    a.save
    get :index, project_id: projects(:linux).to_param
    assert_response :success
    assert_select 'p a.btn.btn-small.btn-danger', text: /remove manager/
  end

  def test_index_for_applicant
    login_as accounts(:umlaut)
    setup_admin_user_umlaut
    get :index, project_id: projects(:linux).to_param
    assert_response :success
    assert @response.body =~ /Pending/i
    assert @response.body =~ /#{accounts(:umlaut).name}/i
  end

  def test_index_for_random
    login_as accounts(:joe)
    setup_admin_user_umlaut
    get :index, project_id: projects(:linux).to_param
    assert_response :success
    assert_equal nil, @response.body =~ /Pending/i
    assert_equal nil, @response.body =~ /#{accounts(:umlaut).name}/i
  end

  def test_index_of_non_existant_project
    login_as accounts(:admin)
    get :index, project_id: 'I_AM_A_BANANA!'
    assert_response :not_found
  end

  def test_index_of_non_existant_organization
    login_as accounts(:admin)
    get :index, organization_id: 'I_AM_A_BANANA!'
    assert_response :not_found
  end

  def test_reject_should_fail_unless_logged_in
    manager_apply(accounts(:user), projects(:linux))
    set_manager(accounts(:admin), projects(:linux))
    login_as accounts(:admin)
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    assert_response :redirect
  end

  def test_reject_should_succeed_for_self
    manager_apply(accounts(:user), projects(:linux))
    login_as accounts(:user)
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    assert_response :redirect
  end

  def test_reject_should_succeed_for_orgs
    manager_apply(accounts(:user), organizations(:linux))
    login_as accounts(:user)
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, organization_id: organizations(:linux).to_param, id: accounts(:user).to_param
    end
    assert_response :redirect
  end

  def test_reject_should_not_succeed_for_unlogged_in
    manager_apply(accounts(:user), projects(:linux))
    assert_no_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    assert_response :unauthorized
  end

  def test_accept_should_succeed_for_manager
    login_as accounts(:admin)
    set_manager(accounts(:admin), projects(:linux))
    manager_apply(accounts(:user), projects(:linux))
    assert_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    assert_equal true, projects(:linux).active_managers.include?(accounts(:user))
    manage = Manage.where(target: projects(:linux), account_id: accounts(:user).id).first
    assert_equal accounts(:admin), manage.approver
    assert_response :redirect
  end

  def test_accept_should_fail_for_not_logged_in
    set_manager(accounts(:admin), projects(:linux))
    manager_apply(accounts(:user), projects(:linux))
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    assert_equal false, projects(:linux).active_managers.include?(accounts(:user))
    assert_response :unauthorized
  end

  def test_accept_should_fail_for_non_manager
    login_as accounts(:joe)
    set_manager(accounts(:admin), projects(:linux)) # joe's logged in but admin's the manager
    manager_apply(accounts(:user), projects(:linux))
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    assert_equal false, projects(:linux).active_managers.include?(accounts(:user))
    assert_response :unauthorized
  end

  def test_accept_should_fail_for_rejected_manager
    login_as accounts(:joe)
    set_manager(accounts(:joe), projects(:linux))
    projects(:linux).manages.each { |pa| pa.update_attributes!(deleted_by: 1) }
    set_manager(accounts(:admin), projects(:linux)) # auto-approved
    manager_apply(accounts(:user), projects(:linux))
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    assert_equal false, projects(:linux).active_managers.include?(accounts(:user))
    assert_response :unauthorized
  end

  def test_new
    login_as accounts(:admin)
    get :new, project_id: projects(:linux).to_param
    assert_response :success
  end

  def test_create
    login_as accounts(:admin)
    assert_difference 'Manage.count' do
      post :create, project_id: projects(:linux).to_param, manage: { message: 'testing' }
      assert_response :redirect
    end
  end

  def test_create_doesnt_allow_books
    login_as accounts(:admin)
    assert_no_difference 'Manage.count' do
      post :create, project_id: projects(:linux).to_param, manage: { message: 'testing' * 1_000 }
      assert_response :unprocessable_entity
    end
  end

  def test_edit
    login_as accounts(:admin)
    admin_manages_linux
    get :edit, project_id: projects(:linux).to_param, id: accounts(:admin).to_param
    assert_response :success
    assert_equal 'test message', assigns(:manage).message
  end

  def test_edit_of_a_non_existant_account
    login_as accounts(:admin)
    get :edit, project_id: projects(:linux).to_param, id: 'I_AM_A_BANANA!'
    assert_response :not_found
  end

  def test_update
    login_as accounts(:admin)
    admin_manages_linux
    post :update, id: accounts(:admin).to_param, project_id: projects(:linux).to_param, manage: { message: 'hihi' }
    assert_equal 'hihi', projects(:linux).reload.manages.first.message
    assert flash[:notice] == 'Save successful!'
  end

  def test_update_doesnt_allow_books
    login_as accounts(:admin)
    admin_manages_linux
    post :update, id: accounts(:admin).to_param, project_id: projects(:linux).to_param,
                  manage: { message: 'testing' * 1_000 }
    assert_response :unprocessable_entity
    assert_equal 'test message', projects(:linux).reload.manages.first.message
  end

  def test_update_wont_edit_someone_elses
    login_as accounts(:user)
    admin_manages_linux
    post :update, id: accounts(:admin).to_param, project_id: projects(:linux).to_param, manage: { message: 'hihi' }
    assert_response :unauthorized
    assert_not_equal 'hihi', projects(:linux).manages.first.message
  end

  protected

  def set_manager(account, project)
    manage = project.manages.create!(account: account, message: 'let me in!')
    manage.update_attributes(approved_by: 1)
    manage
  end

  def manager_apply(account, project)
    manage = project.manages.create!(account: account, message: 'let me in!')
    manage.update_attributes!(approver: nil)
    manage
  end

  def setup_admin_user_umlaut
    set_manager(accounts(:admin), projects(:linux))
    set_manager(accounts(:user), projects(:linux))
    manager_apply(accounts(:umlaut), projects(:linux))
  end

  def admin_manages_linux
    projects(:linux).manages.delete_all
    projects(:linux).manages.create!(account_id: accounts(:admin).id,
                                     approved_by: accounts(:user).id, message: 'test message')
  end
end
