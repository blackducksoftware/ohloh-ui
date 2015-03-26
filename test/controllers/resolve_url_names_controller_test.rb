require 'test_helper'

class ResolveUrlNamesControllerTest < ActionController::TestCase
  # project
  it 'project route should find correct project' do
    project = create(:project, url_name: 'resolve_this_project_buddy')
    get :project, q: 'resolve_THIS_project_buddy'
    must_respond_with :ok
    resp = JSON.parse(response.body)
    resp['id'].must_equal project.id
    resp['url_name'].must_equal project.url_name
    resp['q'].must_equal 'resolve_THIS_project_buddy'
  end

  it 'project route should gracefully handle no such project' do
    get :project, q: 'resolve_wont_find_any_project'
    must_respond_with :ok
    resp = JSON.parse(response.body)
    resp['id'].must_equal nil
    resp['q'].must_equal 'resolve_wont_find_any_project'
  end

  # organization
  it 'organization route should find correct project' do
    organization = create(:organization, url_name: 'resolve_this_organization_buddy')
    get :organization, q: 'resolve_THIS_organization_buddy'
    must_respond_with :ok
    resp = JSON.parse(response.body)
    resp['id'].must_equal organization.id
    resp['url_name'].must_equal organization.url_name
    resp['q'].must_equal 'resolve_THIS_organization_buddy'
  end

  it 'organization route should gracefully handle no such project' do
    get :organization, q: 'resolve_wont_find_any_organization'
    must_respond_with :ok
    resp = JSON.parse(response.body)
    resp['id'].must_equal nil
    resp['q'].must_equal 'resolve_wont_find_any_organization'
  end
end
