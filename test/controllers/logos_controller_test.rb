# frozen_string_literal: true

require_relative '../test_helper.rb'

class LogosControllerTest < ActionController::TestCase
  let(:project) { create(:project) }

  before do
    ActionView::Base.any_instance.stubs(:current_user_can_manage?).returns('true')
    @admin = create(:admin)
    @user = create(:account)
  end

  it 'user should be redirected to login page' do
    post :create, project_id: project.id
    must_respond_with :redirect
    must_redirect_to '/sessions/new'
  end

  it 'upload logo via URL' do
    VCR.use_cassette('LogoClearGif') do
      login_as @admin
      Project.any_instance.stubs(:edit_authorized?).returns(true)
      post :create, project_id: project.id, logo: { url: 'https://www.openhub.net/images/clear.gif' }
      must_redirect_to new_project_logos_path
      project.reload.logo.attachment_file_name.must_equal 'clear.gif'
      project.logo.attachment_content_type.must_equal 'image/gif'
    end
  end

  it 'upload logo for organization via URL' do
    VCR.use_cassette('LogoClearGif') do
      login_as @admin
      organization = create(:organization)
      Organization.any_instance.expects(:edit_authorized?).returns(true)
      post :create, organization_id: organization.id, logo: { url: 'https://www.openhub.net/images/clear.gif' }
      must_redirect_to new_organization_logos_path
      organization.reload.logo.attachment_file_name.must_equal 'clear.gif'
      organization.logo.attachment_content_type.must_equal 'image/gif'
    end
  end

  it 'validate failure' do
    VCR.use_cassette('LogoClearGif') do
      login_as @admin
      Project.any_instance.expects(:edit_authorized?).at_least_once.returns(true)
      post :create, project_id: project.id, logo: { url: 'https://www.dummyhost.net/images/clear.gif' }
      must_respond_with :unprocessable_entity
      must_render_template :new
      flash[:error].must_equal 'Sorry, there was a problem updating the logo'
    end
  end

  it 'upload logo via desktop file' do
    login_as @admin
    Project.any_instance.stubs(:edit_authorized?).returns(true)
    tempfile = Rack::Test::UploadedFile.new('test/data/files/ruby.png', 'image/png')
    post :create, project_id: project.id, logo: { attachment: tempfile }
    must_redirect_to new_project_logos_path
    project.reload.logo.attachment_file_name.must_equal 'ruby.png'
    project.logo.attachment_content_type.must_equal 'image/png'
  end

  it 'open LogosController new for project with no logo renders successfully' do
    get :new, project_id: project.id
    must_respond_with :success
  end

  it 'open LogosController new for organization with no logo renders successfully' do
    organization = create(:organization)

    get :new, organization_id: organization.id
    must_respond_with :success
  end

  it 'must render projects/deleted when project is deleted' do
    project = create(:project)
    project.update!(deleted: true, editor_account: @user)

    get :new, project_id: project.to_param

    must_render_template 'deleted'
  end

  it 'LogosController destroy resets to NilLogo' do
    login_as @admin

    delete :destroy, project_id: project.id

    must_redirect_to new_project_logos_path
    NilClass.must_equal project.reload.logo.class
  end

  it 'LogosController destroy does not really destroy default logos' do
    Logo.where(id: 1180).destroy_all
    logo = create(:logo, id: 1180)
    project = create(:project, logo_id: logo.id)

    login_as @admin

    delete :destroy, project_id: project.id

    must_redirect_to new_project_logos_path
    NilClass.must_equal project.reload.logo.class
    Logo.where(id: 1180).count.must_equal 1
  end

  it 'new unauthenticated' do
    get :new, project_id: project.id
    must_respond_with :success
  end

  it 'must render the new page successfully' do
    login_as @admin

    get :new, project_id: project.id

    must_respond_with :success
    must_render_template :new
  end

  it 'new shows flash if user has no permissions' do
    project = create(:project)
    account = create(:account)
    create(:manage, target: project, account: account)
    create(:permission, target: project, remainder: true)

    login_as create(:account)
    get :new, project_id: project.id

    flash[:notice].must_equal I18n.t('permissions.not_manager')
  end

  it 'create with logo id' do
    login_as @admin
    Project.any_instance.stubs(:edit_authorized?).returns(true)
    desired_new_logo_id = create(:attachment).id
    post :create, project_id: project.id, logo_id: desired_new_logo_id
    must_redirect_to new_project_logos_path(project.id)
    project.reload
    desired_new_logo_id.must_equal project.logo_id
  end

  it 'create requires permissions' do
    project = create(:project, logo: nil)
    create(:manage, target: project, account: create(:account))
    create(:permission, target: project, remainder: true)

    login_as @user
    desired_new_logo_id = create(:attachment).id
    post :create, project_id: project.id, logo_id: desired_new_logo_id
    assert_nil project.reload.logo_id
    must_redirect_to new_session_path
    flash[:error].must_match(/authorized/)
  end
end
