# frozen_string_literal: true

require 'test_helper'

class ManagersControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  let(:account) { create(:account) }
  let(:joe_account) { create(:account, name: 'joe') }
  let(:account_with_umlaut) { create(:account, name: 'ütvon îåa') }

  before do
    @proj = create(:project)
  end

  it 'test index of project for manager' do
    login_as admin
    setup_admin_user_umlaut
    get :index, params: { project_id: @proj.to_param }
    assert_response :success
    _(@response.body).must_match(/Pending/i)
  end

  it 'test index for i manage this project button for admin' do
    login_as admin
    get :index, params: { project_id: @proj.to_param }
    assert_response :success
    assert_select 'a.btn.btn-primary'
    assert_select '.col-md-4 a.btn.btn-primary', text: 'I manage this project on Open Hub'
  end

  it 'must render projects/deleted when project is deleted' do
    login_as admin
    project = create(:project)

    project.update!(deleted: true, editor_account: create(:account))

    get :index, params: { project_id: project.to_param }

    assert_template 'deleted'
  end

  it 'test index for i manage this project button for admin when admin is manager' do
    login_as admin
    a = @proj
    a.editor_account = admin
    a.managers << admin
    a.save
    get :index, params: { project_id: @proj.to_param }
    assert_response :success
    assert_select 'p a.btn.btn-small.btn-danger', text: /remove manager/
  end

  it 'test index for applicant' do
    login_as account_with_umlaut
    setup_admin_user_umlaut
    get :index, params: { project_id: @proj.to_param }
    assert_response :success
    _(@response.body).must_match(/Pending/i)
    _(@response.body).must_match(/#{account_with_umlaut.name}/i)
  end

  it 'test index for random' do
    login_as joe_account
    setup_admin_user_umlaut
    get :index, params: { project_id: @proj.to_param }
    assert_response :success
    _(@response.body).wont_match(/Pending/i)
    _(@response.body).wont_match(/#{account_with_umlaut.name}/i)
  end

  it 'test index of non existant project' do
    login_as admin
    get :index, params: { project_id: 'I_AM_A_BANANA!' }
    assert_response :not_found
  end

  it 'test index of non existant organization' do
    login_as admin
    get :index, params: { organization_id: 'I_AM_A_BANANA!' }
    assert_response :not_found
  end

  it 'test reject should fail unless logged in' do
    manager_apply(account, @proj)
    set_manager(admin, @proj)
    login_as admin
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, params: { project_id: @proj.to_param, id: account.to_param }
    end
    assert_response :redirect
  end

  it 'test reject should succeed for self' do
    manager_apply(account, @proj)
    login_as account
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, params: { project_id: @proj.to_param, id: account.to_param }
    end
    assert_response :redirect
  end

  it 'test reject should succeed for orgs' do
    org = create(:organization)
    manager_apply(account, org)
    login_as account
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, params: { organization_id: org.to_param, id: account.to_param }
    end
    assert_response :redirect
  end

  it 'test reject should not succeed for unlogged in' do
    manager_apply(account, @proj)
    assert_no_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, params: { project_id: @proj.to_param, id: account.to_param }
    end
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  it 'test accept should succeed for manager' do
    login_as admin
    set_manager(admin, @proj)
    manager_apply(account, @proj)
    assert_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, params: { project_id: @proj.to_param, id: account.to_param }
    end
    _(@proj.active_managers.include?(account)).must_equal true
    manage = Manage.where(target: @proj, account_id: account.id).first
    _(manage.approver).must_equal admin
    assert_response :redirect
  end

  it 'test accept should fail for not logged in' do
    set_manager(admin, @proj)
    manager_apply(account, @proj)
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, params: { project_id: @proj.to_param, id: account.to_param }
    end
    _(@proj.active_managers.include?(account)).must_equal false
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  it 'test accept should fail for non manager' do
    login_as joe_account
    set_manager(admin, @proj) # joe's logged in but admin's the manager
    manager_apply(account, @proj)
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, params: { project_id: @proj.to_param, id: account.to_param }
    end
    _(@proj.active_managers.include?(account)).must_equal false
    assert_response :unauthorized
  end

  it 'test accept should fail for rejected manager' do
    login_as joe_account
    set_manager(joe_account, @proj)
    @proj.manages.each { |pa| pa.update!(deleted_by: admin.id, deleted_at: Time.current) }
    set_manager(admin, @proj) # auto-approved
    manager_apply(account, @proj)
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, params: { project_id: @proj.to_param, id: account.to_param }
    end
    _(@proj.active_managers.include?(account)).must_equal false
    assert_response :unauthorized
  end

  it 'test new' do
    login_as admin
    get :new, params: { project_id: @proj.to_param }
    assert_response :success
  end

  it 'test create' do
    login_as admin
    assert_difference 'Manage.count' do
      post :create, params: { project_id: @proj.to_param, manage: { message: 'testing' } }
      assert_response :redirect
    end
  end

  it 'test create doesnt allow books' do
    login_as admin
    assert_no_difference 'Manage.count' do
      post :create, params: { project_id: @proj.to_param, manage: { message: 'testing' * 1_000 } }
      assert_response :unprocessable_entity
    end
  end

  it 'test edit' do
    login_as admin
    admin_manages_linux
    get :edit, params: { project_id: @proj.to_param, id: admin.to_param }
    assert_response :success
    _(assigns(:manage).message).must_equal 'test message'
  end

  it 'test edit for non-admin' do
    proj = create(:project)
    create(:manage, account: create(:admin), target: proj)
    account = create(:account)
    create(:manage, account: account, target: proj)
    login_as account
    get :edit, params: { project_id: proj.to_param, id: account.to_param }
    assert_response :success
  end

  it 'test edit of others manager requests' do
    proj = create(:project)
    create(:manage, account: create(:admin), target: proj)
    account = create(:account)
    create(:manage, account: account, target: proj)
    login_as create(:account)
    get :edit, params: { project_id: proj.to_param, id: account.to_param }
    assert_response :unauthorized
  end

  it 'test edit of a non existant account' do
    login_as admin
    get :edit, params: { project_id: @proj.to_param, id: 'I_AM_A_BANANA!' }
    assert_response :not_found
  end

  it 'test update' do
    login_as admin
    admin_manages_linux
    post :update, params: { id: admin.to_param, project_id: @proj.to_param, manage: { message: 'hihi' } }
    _(@proj.reload.manages.first.message).must_equal 'hihi'
    assert flash[:notice] == 'Save successful!'
  end

  it 'test update doesnt allow books' do
    login_as admin
    admin_manages_linux
    post :update, params: { id: admin.to_param, project_id: @proj.to_param,
                            manage: { message: 'testing' * 1_000 } }
    assert_response :unprocessable_entity
    _(@proj.reload.manages.first.message).must_equal 'test message'
  end

  it 'test update wont edit someone elses' do
    login_as account
    admin_manages_linux
    post :update, params: { id: admin.to_param, project_id: @proj.to_param, manage: { message: 'hihi' } }
    assert_response :unauthorized
    _(@proj.manages.first.message).wont_equal 'hihi'
  end

  protected

  def set_manager(account, project)
    manage = project.manages.create!(account: account, message: 'let me in!')
    manage.update(approved_by: admin.id)
    manage
  end

  def manager_apply(account, project)
    manage = project.manages.create!(account: account, message: 'let me in!')
    manage.update!(approver: nil)
    manage
  end

  def setup_admin_user_umlaut
    set_manager(admin, @proj)
    set_manager(account, @proj)
    manager_apply(account_with_umlaut, @proj)
  end

  def admin_manages_linux
    @proj.manages.delete_all
    @proj.manages.create!(account_id: admin.id, approved_by: account.id, message: 'test message')
  end
end
