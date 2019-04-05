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
    get :index, project_id: @proj.to_param
    must_respond_with :success
    @response.body.must_match(/Pending/i)
  end

  it 'test index for i manage this project button for admin' do
    login_as admin
    get :index, project_id: @proj.to_param
    must_respond_with :success
    must_select 'a.btn.btn-primary'
    assert_select '.col-md-4 a.btn.btn-primary', text: 'I manage this project on Open Hub'
  end

  it 'must render projects/deleted when project is deleted' do
    login_as admin
    project = create(:project)

    project.update!(deleted: true, editor_account: create(:account))

    get :index, project_id: project.to_param

    must_render_template 'deleted'
  end

  it 'test index for i manage this project button for admin when admin is manager' do
    login_as admin
    a = @proj
    a.editor_account = admin
    a.managers << admin
    a.save
    get :index, project_id: @proj.to_param
    must_respond_with :success
    assert_select 'p a.btn.btn-small.btn-danger', text: /remove manager/
  end

  it 'test index for applicant' do
    login_as account_with_umlaut
    setup_admin_user_umlaut
    get :index, project_id: @proj.to_param
    must_respond_with :success
    @response.body.must_match(/Pending/i)
    @response.body.must_match(/#{account_with_umlaut.name}/i)
  end

  it 'test index for random' do
    login_as joe_account
    setup_admin_user_umlaut
    get :index, project_id: @proj.to_param
    must_respond_with :success
    @response.body.wont_match(/Pending/i)
    @response.body.wont_match(/#{account_with_umlaut.name}/i)
  end

  it 'test index of non existant project' do
    login_as admin
    get :index, project_id: 'I_AM_A_BANANA!'
    must_respond_with :not_found
  end

  it 'test index of non existant organization' do
    login_as admin
    get :index, organization_id: 'I_AM_A_BANANA!'
    must_respond_with :not_found
  end

  it 'test reject should fail unless logged in' do
    manager_apply(account, @proj)
    set_manager(admin, @proj)
    login_as admin
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, project_id: @proj.to_param, id: account.to_param
    end
    must_respond_with :redirect
  end

  it 'test reject should succeed for self' do
    manager_apply(account, @proj)
    login_as account
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, project_id: @proj.to_param, id: account.to_param
    end
    must_respond_with :redirect
  end

  it 'test reject should succeed for orgs' do
    org = create(:organization)
    manager_apply(account, org)
    login_as account
    assert_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, organization_id: org.to_param, id: account.to_param
    end
    must_respond_with :redirect
  end

  it 'test reject should not succeed for unlogged in' do
    manager_apply(account, @proj)
    assert_no_difference 'Manage.where.not(deleted_by: nil).count' do
      post :reject, project_id: @proj.to_param, id: account.to_param
    end
    must_respond_with :redirect
    must_redirect_to new_session_path
  end

  it 'test accept should succeed for manager' do
    login_as admin
    set_manager(admin, @proj)
    manager_apply(account, @proj)
    assert_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: @proj.to_param, id: account.to_param
    end
    @proj.active_managers.include?(account).must_equal true
    manage = Manage.where(target: @proj, account_id: account.id).first
    manage.approver.must_equal admin
    must_respond_with :redirect
  end

  it 'test accept should fail for not logged in' do
    set_manager(admin, @proj)
    manager_apply(account, @proj)
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: @proj.to_param, id: account.to_param
    end
    @proj.active_managers.include?(account).must_equal false
    must_respond_with :redirect
    must_redirect_to new_session_path
  end

  it 'test accept should fail for non manager' do
    login_as joe_account
    set_manager(admin, @proj) # joe's logged in but admin's the manager
    manager_apply(account, @proj)
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: @proj.to_param, id: account.to_param
    end
    @proj.active_managers.include?(account).must_equal false
    must_respond_with :unauthorized
  end

  it 'test accept should fail for rejected manager' do
    login_as joe_account
    set_manager(joe_account, @proj)
    @proj.manages.each { |pa| pa.update!(deleted_by: admin.id, deleted_at: Time.current) }
    set_manager(admin, @proj) # auto-approved
    manager_apply(account, @proj)
    assert_no_difference 'Manage.where.not(approved_by: nil).where(deleted_at: nil).count' do
      post :approve, project_id: @proj.to_param, id: account.to_param
    end
    @proj.active_managers.include?(account).must_equal false
    must_respond_with :unauthorized
  end

  it 'test new' do
    login_as admin
    get :new, project_id: @proj.to_param
    must_respond_with :success
  end

  it 'test create' do
    login_as admin
    assert_difference 'Manage.count' do
      post :create, project_id: @proj.to_param, manage: { message: 'testing' }
      must_respond_with :redirect
    end
  end

  it 'test create doesnt allow books' do
    login_as admin
    assert_no_difference 'Manage.count' do
      post :create, project_id: @proj.to_param, manage: { message: 'testing' * 1_000 }
      must_respond_with :unprocessable_entity
    end
  end

  it 'test edit' do
    login_as admin
    admin_manages_linux
    get :edit, project_id: @proj.to_param, id: admin.to_param
    must_respond_with :success
    assigns(:manage).message.must_equal 'test message'
  end

  it 'test edit for non-admin' do
    proj = create(:project)
    create(:manage, account: create(:admin), target: proj)
    account = create(:account)
    create(:manage, account: account, target: proj)
    login_as account
    get :edit, project_id: proj.to_param, id: account.to_param
    must_respond_with :success
  end

  it 'test edit of others manager requests' do
    proj = create(:project)
    create(:manage, account: create(:admin), target: proj)
    account = create(:account)
    create(:manage, account: account, target: proj)
    login_as create(:account)
    get :edit, project_id: proj.to_param, id: account.to_param
    must_respond_with :unauthorized
  end

  it 'test edit of a non existant account' do
    login_as admin
    get :edit, project_id: @proj.to_param, id: 'I_AM_A_BANANA!'
    must_respond_with :not_found
  end

  it 'test update' do
    login_as admin
    admin_manages_linux
    post :update, id: admin.to_param, project_id: @proj.to_param, manage: { message: 'hihi' }
    @proj.reload.manages.first.message.must_equal 'hihi'
    assert flash[:notice] == 'Save successful!'
  end

  it 'test update doesnt allow books' do
    login_as admin
    admin_manages_linux
    post :update, id: admin.to_param, project_id: @proj.to_param,
                  manage: { message: 'testing' * 1_000 }
    must_respond_with :unprocessable_entity
    @proj.reload.manages.first.message.must_equal 'test message'
  end

  it 'test update wont edit someone elses' do
    login_as account
    admin_manages_linux
    post :update, id: admin.to_param, project_id: @proj.to_param, manage: { message: 'hihi' }
    must_respond_with :unauthorized
    @proj.manages.first.message.wont_equal 'hihi'
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
