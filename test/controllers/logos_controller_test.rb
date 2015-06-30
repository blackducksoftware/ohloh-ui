require_relative '../test_helper.rb'

class LogosControllerTest < ActionController::TestCase
  def setup
    ActionView::Base.any_instance.stubs(:current_user_can_manage?).returns('true')
    @admin = create(:admin)
    @user = create(:account)
  end

  it 'user has permissions to edit' do
    # TODO: acts_as_edited
    Project.any_instance.expects(:edit_authorized?).returns(false)
    login_as @user
    post :create, project_id: projects(:linux).id
    must_respond_with :redirect
    must_redirect_to '/sessions/new'
  end

  it 'upload logo via URL' do
    VCR.use_cassette('LogoClearGif') do
      login_as @admin
      project = projects(:linux)
      Project.any_instance.expects(:edit_authorized?).returns(true)
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

  it 'validate failure'do
    VCR.use_cassette('LogoClearGif') do
      login_as @admin
      project = projects(:linux)
      Project.any_instance.expects(:edit_authorized?).at_least_once.returns(true)
      post :create, project_id: project.id, logo: { url: 'https://www.dummyhost.net/images/clear.gif' }
      must_respond_with :unprocessable_entity
      must_render_template :new
      flash[:error].must_equal 'Sorry, there was a problem updating the logo'
    end
  end

  it 'upload logo via desktop file' do
    login_as @admin
    project = projects(:linux)
    Project.any_instance.expects(:edit_authorized?).returns(true)
    tempfile = Rack::Test::UploadedFile.new('test/fixtures/files/ruby.png', 'image/png')
    post :create, project_id: project.id, logo: { attachment: tempfile }
    must_redirect_to new_project_logos_path
    project.reload.logo.attachment_file_name.must_equal 'ruby.png'
    project.logo.attachment_content_type.must_equal 'image/png'
  end

  it 'open LogosController new for project with no logo renders successfully' do
    project = projects(:linux)

    get :new, project_id: project.id
    must_respond_with :success
  end

  it 'open LogosController new for organization with no logo renders successfully' do
    organization = create(:organization)

    get :new, organization_id: organization.id
    must_respond_with :success
  end

  it 'LogosController destroy resets to NilLogo' do
    project = create(:project)
    login_as @admin

    delete :destroy, project_id: project.id

    must_redirect_to new_project_logos_path
    NilClass.must_equal project.reload.logo.class
  end

  it 'must render projects/deleted when project is deleted' do
    project = create(:project)
    account = create(:account)

    login_as account
    project.update!(deleted: true, editor_account: account)

    get :new, project_id: project.id

    must_render_template 'deleted'
  end

  it 'new unauthenticated' do
    get :new, project_id: projects(:linux).id
    must_respond_with :success
  end

  it 'new' do
    skip('TODO: application')
    login_as @admin
    get :new, project_id: projects(:linux).id
    must_respond_with :success
    'form[action=?]'.must_select project_logos_path do
      assert_select 'input[type=radio][name=logo_id]'
      assert_select 'input[type=submit]'
    end
  end

  it 'new shows flash if user has no permissions' do
    skip('TODO: manage')
    Manage.create!(target: projects(:linux), account: create(:account))
    Permission.create!(project: projects(:linux), 'remainder' => true)

    login_as @user
    get :new, project_id: projects(:linux).id
    flash[:notice].must_equal 'You can view, but not change this data. Only managers may change this data.'
  end

  it 'create with logo id' do
    login_as @admin
    Project.any_instance.expects(:edit_authorized?).returns(true)
    desired_new_logo_id = create(:attachment).id
    post :create, project_id: projects(:linux).id, logo_id: desired_new_logo_id
    must_redirect_to new_project_logos_path(projects(:linux).id)
    projects(:linux).reload
    desired_new_logo_id.must_equal projects(:linux).logo_id
  end

  it 'create requires permissions' do
    project = create(:project, logo: nil)
    create(:manage, target: project, account: create(:account))
    create(:permission, target: project, remainder: true)

    login_as @user
    desired_new_logo_id = create(:attachment).id
    post :create, project_id: project.id, logo_id: desired_new_logo_id
    project.reload.logo_id.must_equal nil
    must_redirect_to new_session_path
    flash[:error].must_match(/authorized/)
  end
end
