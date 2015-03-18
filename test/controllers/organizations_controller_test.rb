require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  before do
    @proj1 = create(:project)
    @proj2 = create(:project)
    @proj3 = create(:project)
    @organization = @proj1.organization
    @account = create(:account, organization_id: @organization.id)
    create_position(account: @account, project: @proj1, organization: @organization)
    create_position(account: @account, project: @proj2, organization: @proj2.organization)
    create_position(account: @account, project: @proj3, organization: @proj3.organization)
  end

  it '#outside_projects allows viewing by unlogged users' do
    login_as nil
    get :outside_projects, id: @organization
    must_respond_with :ok
  end

  it '#outside_projects gracefully handles non-existant organizations' do
    get :outside_projects, id: 'I_AM_A_BANANA'
    must_respond_with :not_found
  end

  it '#affiliated_committers allows viewing by unlogged users' do
    login_as nil
    get :affiliated_committers, id: @organization
    must_respond_with :ok
  end

  it '#affiliated_committers gracefully handles non-existant organizations' do
    get :affiliated_committers, id: 'I_AM_A_BANANA'
    must_respond_with :not_found
  end

  it 'should return affiliated projects for unlogged users' do
    login_as nil
    get :projects, id: @organization
    must_respond_with :ok
    assigns(:affiliated_projects).count.must_equal 1
  end

  it 'outside_committers' do
    get :outside_committers, id: @organization
    must_respond_with :ok
  end

  it 'should get show page for a valid organization' do
    get :show, id: @organization
    must_respond_with :ok
    assert_select 'div#org_summary'
    assert_select 'div#addthis_sharing'
    assert_select 'div#org_infographic'
  end

  it 'should get show page for a invalid organization' do
    get :show, id: 'some_invalid_id'
    must_respond_with :not_found
  end

  it 'should get infographic print view' do
    get :print_infographic, id: @organization
    must_respond_with :ok
  end
end
