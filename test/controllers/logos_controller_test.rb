require_relative '../test_helper.rb'

class LogosControllerTest < ActionController::TestCase
  def setup
    ActionView::Base.any_instance.stubs(:has_permission?).returns('true')
    @admin = accounts(:admin)
    @user = accounts(:user)
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
    login_as @admin
    project = projects(:linux)
    Project.any_instance.expects(:edit_authorized?).returns(true)
    post :create, project_id: project.id, logo: { url: 'https://www.openhub.net/images/clear.gif' }
    must_redirect_to new_project_logos_path
    project.reload.logo.attachment_file_name.must_equal 'clear.gif'
    project.logo.attachment_content_type.must_equal 'image/gif'
  end

  it 'upload logo for organization via URL' do
    login_as @admin
    organization = organizations(:linux)
    Organization.any_instance.expects(:edit_authorized?).returns(true)
    post :create, organization_id: organization.id, logo: { url: 'https://www.openhub.net/images/clear.gif' }
    must_redirect_to new_organization_logos_path
    organization.reload.logo.attachment_file_name.must_equal 'clear.gif'
    organization.logo.attachment_content_type.must_equal 'image/gif'
  end

  it 'validate failure'do
    login_as @admin
    project = projects(:linux)
    Project.any_instance.expects(:edit_authorized?).returns(true)
    post :create, project_id: project.id, logo: { url: 'https://www.dummyhost.net/images/clear.gif' }
    must_redirect_to new_project_logos_path
    flash[:error].must_equal 'Sorry, there was a problem updating the logo'
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

  it 'LogosController destroy resets to NilLogo' do
    project = projects(:linux)
    login_as @admin

    delete :destroy, project_id: project.id

    must_redirect_to new_project_logos_path
    NilClass.must_equal project.reload.logo.class
  end

  it 'new logos page for a deleted project is rendered using the projects/deleted template' do
    skip('TODO: projects')
    project = projects(:linux)

    edit_as :robin do
      project.update_attribute(:deleted, true)
    end

    get :new, project_id: project.id

    must_respond_with :success
    must_render_template 'projects/deleted'
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
    Manage.create!(target: projects(:linux), account: accounts(:user))
    Permission.create!(project: projects(:linux), 'remainder' => true)

    login_as @user
    get :new, project_id: projects(:linux).id
    flash[:notice].must_equal 'You can view, but not change this data. Only managers may change this data.'
  end

  it 'create with logo id' do
    login_as @admin
    Project.any_instance.expects(:edit_authorized?).returns(true)
    desired_new_logo_id = attachments(:random_logo).id
    post :create, project_id: projects(:linux).id, logo_id: desired_new_logo_id
    must_redirect_to new_project_logos_path(projects(:linux).id)
    projects(:linux).reload
    desired_new_logo_id.must_equal projects(:linux).logo_id
  end

  it 'create requires permissions' do
    skip('TODO: manage')
    Manage.create!(target: projects(:linux), account: accounts(:user))
    Permission.create!(project: projects(:linux), 'remainder' => true)

    login_as @user
    desired_new_logo_id = attachments(:new_logo).id
    assert_no_difference('projects(:linux).reload.logo_id') do
      post :create, project_id: projects(:linux).id, logo_id: desired_new_logo_id
    end
    must_redirect_to new_session_path
    flash[:error].must_match(/authorized/)
  end
end
