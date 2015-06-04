require 'test_helper'
require 'test_helpers/xml_parsing_helpers'

describe 'OrganizationsController' do
  let(:account) { create(:account) }
  let(:organization) { create(:organization) }

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

  it 'should support show page via xhr' do
    xhr :get, :show, id: @organization
    must_respond_with :ok
    JSON.parse(response.body)['subview_html'].must_match 'Affiliated Committers'
  end

  it 'should support ?view=portfolio_projects for show action' do
    get :show, id: @organization, view: 'portfolio_projects'
    must_respond_with :ok
    assert_select 'div#org_summary'
  end

  it 'should get show page for a invalid organization' do
    get :show, id: 'some_invalid_id'
    must_respond_with :not_found
  end

  it 'should get infographic print view' do
    get :print_infographic, id: @organization
    must_respond_with :ok
  end

  describe 'settings' do
    it 'must ask user to log in' do
      restrict_edits_to_managers(organization, account)

      get :settings, id: organization.to_param

      flash[:notice].must_equal I18n.t('permissions.must_log_in')
    end

    it 'must alert non managers about read only data' do
      restrict_edits_to_managers(organization, account)
      login_as account

      get :settings, id: organization.to_param

      flash[:notice].must_equal I18n.t('permissions.not_manager')
    end

    it 'must alert non managers even if project and organization url name are same' do
      create(:project, url_name: organization.to_param)
      restrict_edits_to_managers(organization, account)
      login_as account

      get :settings, id: organization.to_param

      flash[:notice].must_equal I18n.t('permissions.not_manager')
    end

    it 'wont show permission alert to an authorized manager' do
      create(:manage, target: organization, account: account)
      restrict_edits_to_managers(organization, account)

      login_as account
      get :settings, id: organization.to_param

      flash[:notice].must_be_nil
    end
  end

  describe 'index' do
    it 'should redirect to explores path' do
      get :index

      must_redirect_to orgs_explores_path
    end

    it 'should return organizations when search term is present' do
      org_1 = create(:organization, name: 'test name1', projects_count: 2)
      org_2 = create(:organization, name: 'test name2', projects_count: 3)
      org_3 = create(:organization, name: 'test name3', projects_count: 4)

      get :index, query: 'test'

      must_respond_with :ok
      assigns(:organizations).must_equal [org_3, org_2, org_1]
    end

    it 'should return organizations via xml' do
      create(:organization, name: 'test name1', projects_count: 2)
      create(:organization, name: 'test name2', projects_count: 3)
      org_3 = create(:organization, name: 'test name3', projects_count: 4, description: 'test description')

      api_key = create(:api_key, account_id: account.id)
      client_id = api_key.oauth_application.uid

      get :index, format: :xml, api_key: client_id, query: 'test'

      xml = xml_hash(@response.body)['response']

      must_respond_with :ok
      xml['status'].must_equal 'success'
      xml['items_returned'].must_equal '3'
      xml['items_available'].must_equal '3'
      xml['first_item_position'].must_equal '0'
      org = xml['result']['organization'].first
      xml['result']['organization'].length.must_equal 3
      org['name'].must_equal 'test name3'
      org['url'].must_equal "http://test.host/orgs/#{org_3.url_name}.xml"
      org['html_url'].must_equal "http://test.host/orgs/#{org_3.url_name}"
      org['description'].must_equal 'test description'
      org['url_name'].must_equal org_3.url_name
      org['type'].must_equal 'Commercial'
      org['projects_count'].must_equal '4'
      org['affiliated_committers'].must_equal '0'
    end

    it 'should return unauthorized if api key is invalid' do
      get :index, format: :xml, api_key: 'dummy_id'

      must_respond_with :unauthorized
    end
  end

  describe 'list_managers' do
    it 'should return managers' do
      create(:manage, target: organization, account: account)
      get :list_managers, id: organization.id
      must_respond_with :ok

      assigns(:managers).must_equal [account]
    end
  end

  describe 'claim_projects_list' do
    it 'should return no projects without search term' do
      get :claim_projects_list, id: organization.to_param

      must_respond_with :ok

      assigns(:projects).must_equal []
      assigns(:organization).must_equal organization
    end

    it 'should return projects with search term' do
      pro_1 = create(:project, name: 'test name1')
      pro_2 = create(:project, name: 'test name2')
      pro_3 = create(:project, name: 'test name3')

      get :claim_projects_list, id: organization.to_param, query: 'test'

      must_respond_with :ok

      assigns(:projects).must_equal [pro_1, pro_2, pro_3]
      assigns(:organization).must_equal organization
    end

    it 'should return projects with search term with sorting' do
      pro_1 = create(:project, name: 'test name1')
      pro_2 = create(:project, name: 'test name2')
      pro_3 = create(:project, name: 'test name3')

      get :claim_projects_list, id: organization.to_param, query: 'test', sort: 'new'

      must_respond_with :ok

      assigns(:projects).must_equal [pro_3, pro_2, pro_1]
      assigns(:organization).must_equal organization
    end
  end

  describe 'manage_projects' do
    it 'should return org managed projects' do
      pro_1 = create(:project, name: 'test name1', organization_id: organization.id)
      pro_2 = create(:project, name: 'test name2', organization_id: organization.id)
      pro_3 = create(:project, name: 'test name3', organization_id: organization.id)

      get :manage_projects, id: organization.to_param, query: 'test'

      must_respond_with :ok

      assigns(:projects).must_equal [pro_3, pro_2, pro_1]
      assigns(:organization).must_equal organization
    end

    it 'should return org managed projects with sorting' do
      pro_1 = create(:project, name: 'test name1', organization_id: organization.id)
      pro_2 = create(:project, name: 'test name2', organization_id: organization.id)
      pro_3 = create(:project, name: 'test name3', organization_id: organization.id)

      get :manage_projects, id: organization.to_param, query: 'test', sort: 'project_name'

      must_respond_with :ok

      assigns(:projects).must_equal [pro_1, pro_2, pro_3]
      assigns(:organization).must_equal organization
    end
  end

  describe 'claim_project' do
    it 'should claim a project for the given org' do
      login_as account
      pro_1 = create(:project, name: 'test name1')
      xhr :get, :claim_project, id: organization.to_param, project_id: pro_1.id

      must_respond_with :ok
      assigns(:project).organization_id.must_equal organization.id
    end
  end

  describe 'remove_project' do
    it 'should remove project from org' do
      login_as account
      pro_1 = create(:project, name: 'test name1', organization_id: organization.id)

      get :remove_project, id: organization.to_param, project_id: pro_1.id

      must_redirect_to manage_projects_organization_path(organization)
      flash[:success].must_equal I18n.t('organizations.remove_project.success', name: pro_1.name)
      pro_1.reload.organization_id.must_equal nil
    end
  end

  describe 'new_manager' do
    it 'should show new manager form for get request' do
      get :new_manager, id: organization, account_id: account.id
      must_respond_with :ok
    end

    it 'should show new manager form for get request' do
      post :new_manager, id: organization, account_id: account.id

      must_redirect_to list_managers_organization_path(organization)
      assigns(:manage).target organization
    end
  end

  describe 'create' do
    it 'should show validation errors' do
      account.update_column(:level, 10)
      login_as account
      post :create, organization: { name: 'test', description: 'tes', url_name: '',
                                    org_type: '2', homepage_url: 'http://test.com' }

      must_respond_with :ok
      assigns(:organization).errors[:url_name].must_equal ['can\'t be blank', 'is too short (minimum is 1 character)']
    end

    it 'should save record successfully' do
      account.update_column(:level, 10)
      login_as account
      post :create, organization: { name: 'test', description: 'tes', url_name: 'test',
                                    org_type: '2', homepage_url: 'http://test.com' }

      must_redirect_to organization_path(assigns(:organization))
      assigns(:organization).valid?.must_equal true
    end
  end

  describe 'update' do
    it 'should show validation errors' do
      login_as account
      account.update_column(:level, 10)
      org = create(:organization, name: 'test')
      put :update, id: org.id, organization: { name: '', description: 'tes', url_name: 'test',
                                               org_type: '2', homepage_url: 'http://test.com' }

      must_respond_with 422
      assigns(:organization).errors[:name].must_equal ['can\'t be blank', 'is too short (minimum is 3 characters)']
    end

    it 'should save record successfully' do
      account.update_column(:level, 10)
      login_as account
      org = create(:organization, name: 'test')
      put :update, id: org.id, organization: { name: 'test2', description: 'tes', url_name: 'test',
                                               org_type: '2', homepage_url: 'http://test.com' }

      must_redirect_to organization_path(assigns(:organization))
      assigns(:organization).name.must_equal 'test2'
      assigns(:organization).valid?.must_equal true
    end
  end

  describe 'edit' do
    it 'should set organization' do
      login_as account
      account.update_column(:level, 10)
      org = create(:organization, name: 'test')
      get :edit, id: org.id
      assigns(:organization).must_equal org
    end
  end

  describe 'new' do
    it 'should set new organization' do
      login_as account
      account.update_column(:level, 10)
      get :new
      assigns(:organization).new_record?.must_equal true
    end
  end
end
