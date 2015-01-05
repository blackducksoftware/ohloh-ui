require_relative '../test_helper.rb'

class LogosControllerTest < ActionController::TestCase
  def setup
    ActionView::Base.any_instance.stubs(:has_permission?).returns('true')
    @admin = accounts(:admin)
    @user = accounts(:user)
  end

  test 'user has permissions to edit' do
    # TODO: acts_as_edited
    Project.any_instance.expects(:edit_authorized?).returns(false)
    login_as @user
    post :create, project_id: projects(:linux).id
    assert_response :redirect
    assert_redirected_to '/sessions/new'
  end

  test 'upload logo via URL' do
    login_as @admin
    project = projects(:linux)
    Project.any_instance.expects(:edit_authorized?).returns(true)
    post :create, project_id: project.id, logo: { url: 'https://www.openhub.net/images/clear.gif' }
    assert_redirected_to new_project_logos_path
    assert_equal project.reload.logo.attachment_file_name, 'clear.gif'
    assert_equal project.logo.attachment_content_type, 'image/gif'
  end

  test 'upload logo for organization via URL' do
    login_as @admin
    organization = organizations(:linux)
    Organization.any_instance.expects(:edit_authorized?).returns(true)
    post :create, organization_id: organization.id, logo: { url: 'https://www.openhub.net/images/clear.gif' }
    assert_redirected_to new_organization_logos_path
    assert_equal organization.reload.logo.attachment_file_name, 'clear.gif'
    assert_equal organization.logo.attachment_content_type, 'image/gif'
  end

  test 'validate failure'do
    login_as @admin
    project = projects(:linux)
    Project.any_instance.expects(:edit_authorized?).returns(true)
    post :create, project_id: project.id, logo: { url: 'https://www.dummyhost.net/images/clear.gif' }
    assert_redirected_to new_project_logos_path
    assert_equal 'Sorry, there was a problem updating the logo', flash[:error]
  end

  test 'upload logo via desktop file' do
    login_as @admin
    project = projects(:linux)
    Project.any_instance.expects(:edit_authorized?).returns(true)
    tempfile = Rack::Test::UploadedFile.new('test/fixtures/files/ruby.png', 'image/png')
    post :create, project_id: project.id, logo: { attachment: tempfile }
    assert_redirected_to new_project_logos_path
    assert_equal project.reload.logo.attachment_file_name, 'ruby.png'
    assert_equal project.logo.attachment_content_type, 'image/png'
  end

  test 'open LogosController new for project with no logo renders successfully' do
    project = projects(:linux)

    get :new, project_id: project.id
    assert_response :success
  end

  test 'LogosController destroy resets to NilLogo' do
    project = projects(:linux)
    login_as @admin

    delete :destroy, project_id: project.id

    assert_redirected_to new_project_logos_path
    assert_equal NilClass, project.reload.logo.class
  end

  test 'new logos page for a deleted project is rendered using the projects/deleted template' do
    skip('TODO: projects')
    project = projects(:linux)

    edit_as :robin do
      project.update_attribute(:deleted, true)
    end

    get :new, project_id: project.id

    assert_response :success
    assert_template 'projects/deleted'
  end

  test 'new unauthenticated' do
    get :new, project_id: projects(:linux).id
    assert_response :success
  end

  test 'new' do
    skip('TODO: application')
    login_as @admin
    get :new, project_id: projects(:linux).id
    assert_response :success
    assert_select 'form[action=?]', project_logos_path do
      assert_select 'input[type=radio][name=logo_id]'
      assert_select 'input[type=submit]'
    end
  end

  test 'new shows flash if user has no permissions' do
    skip('TODO: manage')
    with_editor :jason do
      Manage.create!(project: projects(:linux), account: accounts(:robin))
      Permission.create!(project: projects(:linux), 'remainder' => true)
    end

    login_as @user
    get :new, project_id: projects(:linux).id
    assert_equal 'You can view, but not change this data. Only managers may change this data.', flash[:notice]
  end

  test 'create with logo id' do
    # TODO: acts_as_edited
    login_as @admin
    Project.any_instance.expects(:edit_authorized?).returns(true)
    desired_new_logo_id = attachments(:random_logo).id
    post :create, project_id: projects(:linux).id, logo_id: desired_new_logo_id
    assert_redirected_to new_project_logos_path(projects(:linux).id)
    projects(:linux).reload
    assert_equal desired_new_logo_id, projects(:linux).logo_id
  end

  test 'create requires permissions' do
    skip('TODO: manage')
    with_editor :jason do
      Manage.create!(project: projects(:linux), account: accounts(:robin))
      Permission.create!(project: projects(:linux), 'remainder' => true)
    end

    login_as @user
    desired_new_logo_id = attachments(:new_logo).id
    assert_no_difference('projects(:linux).reload.logo_id') do
      post :create, project_id: projects(:linux).id, logo_id: desired_new_logo_id
    end
    assert_redirected_to new_session_path
    assert flash[:error] =~ /authorized/
  end
end
