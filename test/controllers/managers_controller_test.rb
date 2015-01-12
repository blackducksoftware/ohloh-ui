require 'test_helper'

class ManagersControllerTest < ActionController::TestCase
  it 'test index of project for manager' do
    login_as accounts(:admin)
    setup_admin_user_umlaut
    get :index, project_id: projects(:linux).to_param
    must_respond_with :success
    @response.body.must_match(/Pending/i)
  end

  it 'test index for i manage this project button for admin' do
    login_as accounts(:admin)
    get :index, project_id: projects(:linux).to_param
    must_respond_with :success
    assert_tag tag: 'a', attributes: { class: 'btn btn-primary' }
    assert_select '.col-md-4 a.btn.btn-primary', text: 'I manage this project on Open Hub'
  end

  it 'test index for i manage this project button for admin when admin is manager' do
    login_as accounts(:admin)
    a = projects(:linux)
    a.editor_account = accounts(:admin)
    a.managers << accounts(:admin)
    a.save
    get :index, project_id: projects(:linux).to_param
    must_respond_with :success
    assert_select 'p a.btn.btn-small.btn-danger', text: /remove manager/
  end

  it 'test index for applicant' do
    login_as accounts(:umlaut)
    setup_admin_user_umlaut
    get :index, project_id: projects(:linux).to_param
    must_respond_with :success
    @response.body.must_match(/Pending/i)
    @response.body.must_match(/#{accounts(:umlaut).name}/i)
  end

  it 'test index for random' do
    login_as accounts(:joe)
    setup_admin_user_umlaut
    get :index, project_id: projects(:linux).to_param
    must_respond_with :success
    @response.body.wont_match(/Pending/i)
    @response.body.wont_match(/#{accounts(:umlaut).name}/i)
  end

  it 'test index of non existant project' do
    login_as accounts(:admin)
    get :index, project_id: 'I_AM_A_BANANA!'
    must_respond_with :not_found
  end

  it 'test index of non existant organization' do
    login_as accounts(:admin)
    get :index, organization_id: 'I_AM_A_BANANA!'
    must_respond_with :not_found
  end

  it 'test reject should fail unless logged in' do
    manager_apply(accounts(:user), projects(:linux))
    set_manager(accounts(:admin), projects(:linux))
    login_as accounts(:admin)
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    must_respond_with :redirect
  end

  it 'test reject should succeed for self' do
    manager_apply(accounts(:user), projects(:linux))
    login_as accounts(:user)
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    must_respond_with :redirect
  end

  it 'test reject should succeed for orgs' do
    manager_apply(accounts(:user), organizations(:linux))
    login_as accounts(:user)
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, organization_id: organizations(:linux).to_param, id: accounts(:user).to_param
    end
    must_respond_with :redirect
  end

  it 'test reject should not succeed for unlogged in' do
    manager_apply(accounts(:user), projects(:linux))
    assert_no_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    must_respond_with :unauthorized
  end

  it 'test accept should succeed for manager' do
    login_as accounts(:admin)
    set_manager(accounts(:admin), projects(:linux))
    manager_apply(accounts(:user), projects(:linux))
    assert_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    projects(:linux).active_managers.include?(accounts(:user)).must_equal true
    manage = Manage.where(target: projects(:linux), account_id: accounts(:user).id).first
    manage.approver.must_equal accounts(:admin)
    must_respond_with :redirect
  end

  it 'test accept should fail for not logged in' do
    set_manager(accounts(:admin), projects(:linux))
    manager_apply(accounts(:user), projects(:linux))
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    projects(:linux).active_managers.include?(accounts(:user)).must_equal false
    must_respond_with :unauthorized
  end

  it 'test accept should fail for non manager' do
    login_as accounts(:joe)
    set_manager(accounts(:admin), projects(:linux)) # joe's logged in but admin's the manager
    manager_apply(accounts(:user), projects(:linux))
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    projects(:linux).active_managers.include?(accounts(:user)).must_equal false
    must_respond_with :unauthorized
  end

  it 'test accept should fail for rejected manager' do
    login_as accounts(:joe)
    set_manager(accounts(:joe), projects(:linux))
    projects(:linux).manages.each { |pa| pa.update_attributes!(deleted_by: 1, deleted_at: Time.now.utc) }
    set_manager(accounts(:admin), projects(:linux)) # auto-approved
    manager_apply(accounts(:user), projects(:linux))
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: projects(:linux).to_param, id: accounts(:user).to_param
    end
    projects(:linux).active_managers.include?(accounts(:user)).must_equal false
    must_respond_with :unauthorized
  end

  it 'test new' do
    login_as accounts(:admin)
    get :new, project_id: projects(:linux).to_param
    must_respond_with :success
  end

  it 'test create' do
    login_as accounts(:admin)
    assert_difference 'Manage.count' do
      post :create, project_id: projects(:linux).to_param, manage: { message: 'testing' }
      must_respond_with :redirect
    end
  end

  it 'test create doesnt allow books' do
    login_as accounts(:admin)
    assert_no_difference 'Manage.count' do
      post :create, project_id: projects(:linux).to_param, manage: { message: 'testing' * 1_000 }
      must_respond_with :unprocessable_entity
    end
  end

  it 'test edit' do
    login_as accounts(:admin)
    admin_manages_linux
    get :edit, project_id: projects(:linux).to_param, id: accounts(:admin).to_param
    must_respond_with :success
    assigns(:manage).message.must_equal 'test message'
  end

  it 'test edit of a non existant account' do
    login_as accounts(:admin)
    get :edit, project_id: projects(:linux).to_param, id: 'I_AM_A_BANANA!'
    must_respond_with :not_found
  end

  it 'test update' do
    login_as accounts(:admin)
    admin_manages_linux
    post :update, id: accounts(:admin).to_param, project_id: projects(:linux).to_param, manage: { message: 'hihi' }
    projects(:linux).reload.manages.first.message.must_equal 'hihi'
    assert flash[:notice] == 'Save successful!'
  end

  it 'test update doesnt allow books' do
    login_as accounts(:admin)
    admin_manages_linux
    post :update, id: accounts(:admin).to_param, project_id: projects(:linux).to_param,
                  manage: { message: 'testing' * 1_000 }
    must_respond_with :unprocessable_entity
    projects(:linux).reload.manages.first.message.must_equal 'test message'
  end

  it 'test update wont edit someone elses' do
    login_as accounts(:user)
    admin_manages_linux
    post :update, id: accounts(:admin).to_param, project_id: projects(:linux).to_param, manage: { message: 'hihi' }
    must_respond_with :unauthorized
    projects(:linux).manages.first.message.wont_equal 'hihi'
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
