require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  before do
    @proj1 = create(:project)
    @proj2 = create(:project)
    @proj3 = create(:project)
    @organization = @proj1.organization
    @account = create(:account, organization_id: @organization.id)
    create(:position, account: @account, project: @proj1, organization: @organization)
    create(:position, account: @account, project: @proj2, organization: @proj2.organization)
    create(:position, account: @account, project: @proj3, organization: @proj3.organization)
  end

  it 'allows viewing by unlogged users' do
    login_as nil
    get :outside_projects, id: @organization
    must_respond_with :ok
  end

  it 'gracefully handles non-existant organizations' do
    get :outside_projects, id: 'I_AM_A_BANANA'
    must_respond_with :not_found
  end

  it 'outside_committers' do
    get :outside_committers, id: @organization
    must_respond_with :ok
  end
end
