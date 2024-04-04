# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/xml_parsing_helpers'

class OrganizationsControllerTest < ActionController::TestCase
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
    get :outside_projects, params: { id: @organization }
    assert_response :ok
  end

  it '#outside_projects can be accessed via the API' do
    api_key = create(:api_key, account_id: account.id)
    get :outside_projects, params: { id: @organization, format: :xml, api_key: api_key.oauth_application.uid }
    assert_response :ok
  end

  it '#outside_projects gracefully handles non-existant organizations' do
    get :outside_projects, params: { id: 'I_AM_A_BANANA' }
    assert_response :not_found
  end

  it '#affiliated_committers allows viewing by unlogged users' do
    login_as nil
    get :affiliated_committers, params: { id: @organization }
    assert_response :ok
  end

  it '#affiliated_committers supports xml api' do
    api_key = create(:api_key, account_id: account.id)
    get :affiliated_committers, params: { id: @organization, format: :xml, api_key: api_key.oauth_application.uid }
    assert_response :ok
  end

  it '#affiliated_committers gracefully handles non-existant organizations' do
    get :affiliated_committers, params: { id: 'I_AM_A_BANANA' }
    assert_response :not_found
  end

  it 'should return affiliated projects for unlogged users' do
    login_as nil
    get :projects, params: { id: @organization }
    assert_response :ok
    _(assigns(:affiliated_projects).count).must_equal 1
  end

  it 'outside_committers' do
    get :outside_committers, params: { id: @organization }
    assert_response :ok
  end

  it 'should get outside_committers in xml format with valid api key' do
    key = create(:api_key, account_id: @account.id)
    get :outside_committers, params: { id: @organization, format: :xml, api_key: key.oauth_application.uid }
    assert_response :ok
  end

  it 'should get show page for a valid organization' do
    get :show, params: { id: @organization }
    assert_response :ok
    assert_select 'div#org_summary'
    assert_select 'div#addthis_sharing'
    assert_select 'div#org_infographic'
  end

  it 'show must strip tags from description' do
    @organization.update! description: "foo \n <link>"

    get :show, params: { id: @organization.vanity_url }

    _(assert_select('p')[3].text).must_equal "foo \n "
  end

  it 'should support show page via xml api' do
    key = create(:api_key, account_id: create(:account).id)
    get :show, params: { id: @organization, format: :xml, api_key: key.oauth_application.uid }
    assert_response :ok
  end

  it 'show should render for organizations that contain projects that have been analyzed' do
    organization = create(:organization)
    project = create(:project, organization: organization)
    af1 = create(:activity_fact, analysis: project.best_analysis, code_added: 8_000, comments_added: 8_000)
    create(:factoid, analysis: project.best_analysis, language: af1.language)
    af2 = create(:activity_fact, analysis: project.best_analysis)
    create(:factoid, analysis: project.best_analysis, language: af2.language)
    af3 = create(:activity_fact, analysis: project.best_analysis)
    create(:factoid, analysis: project.best_analysis, language: af3.language)
    af4 = create(:activity_fact, analysis: project.best_analysis)
    create(:factoid, analysis: project.best_analysis, language: af4.language)
    ats = project.best_analysis.all_time_summary
    ats.update(recent_contributors: [create(:person).id, create(:person).id])
    cf = create(:commit_flag)
    create(:analysis_sloc_set, analysis: project.best_analysis, sloc_set: cf.sloc_set)
    key = create(:api_key, account_id: create(:account).id)
    get :show, params: { id: organization.to_param, format: :xml, api_key: key.oauth_application.uid }
    assert_response :ok
  end

  it 'should support show page via xhr' do
    get :show, params: { id: @organization }, xhr: true
    assert_response :ok
    _(JSON.parse(response.body)['subview_html']).must_match 'Affiliated Committers'
  end

  it 'should support ?view=portfolio_projects for show action' do
    get :show, params: { id: @organization, view: 'portfolio_projects' }
    assert_response :ok
    assert_select 'div#org_summary'
  end

  it 'should support projects view as xml' do
    key = create(:api_key, account_id: create(:account).id)
    get :show, params: { id: @organization, format: :xml, api_key: key.oauth_application.uid }
    assert_response :ok
  end

  it 'should get show page for a invalid organization' do
    get :show, params: { id: 'some_invalid_id' }
    assert_response :not_found
  end

  it 'should get infographic print view' do
    get :print_infographic, params: { id: @organization }
    assert_response :ok
  end

  describe 'settings' do
    it 'must ask user to log in' do
      restrict_edits_to_managers(organization, account)

      get :settings, params: { id: organization.to_param }

      _(flash[:notice]).must_equal I18n.t('permissions.must_log_in')
    end

    it 'must alert non managers about read only data' do
      admin = create(:admin)
      create(:manage, target: organization, account: admin, approved_by: admin.id)
      restrict_edits_to_managers(organization, admin)
      login_as account

      get :settings, params: { id: organization.to_param }

      _(flash[:notice]).must_equal I18n.t('permissions.not_manager')
    end

    it 'must alert non managers even if project and organization url name are same' do
      create(:project, vanity_url: organization.to_param)
      restrict_edits_to_managers(organization, account)
      login_as account

      get :settings, params: { id: organization.to_param }

      _(flash[:notice]).must_equal I18n.t('permissions.not_manager')
    end

    it 'wont show permission alert to an authorized manager' do
      create(:manage, target: organization, account: account, approved_by: create(:admin).id)
      restrict_edits_to_managers(organization, account)

      login_as account
      get :settings, params: { id: organization.to_param }

      _(flash[:notice]).must_be_nil
    end
  end

  describe 'index' do
    it 'should redirect to explores path' do
      get :index

      assert_redirected_to orgs_explores_path
    end

    it 'should return organizations when search term is present' do
      org1 = create(:organization, name: 'test name1', projects_count: 2)
      org2 = create(:organization, name: 'test name2', projects_count: 3)
      org3 = create(:organization, name: 'test name3', projects_count: 4)

      get :index, params: { query: 'test' }

      assert_response :ok
      _(assigns(:organizations)).must_equal [org3, org2, org1]
    end

    it 'should return organizations via xml' do
      create(:organization, name: 'test name1', projects_count: 2)
      create(:organization, name: 'test name2', projects_count: 3)
      org3 = create(:organization, name: 'test name3', projects_count: 4, description: 'test description')

      api_key = create(:api_key, account_id: account.id)
      client_id = api_key.oauth_application.uid

      get :index, params: { format: :xml, api_key: client_id, query: 'test' }

      xml = xml_hash(@response.body)['response']

      assert_response :ok
      _(xml['status']).must_equal 'success'
      _(xml['items_returned']).must_equal '3'
      _(xml['items_available']).must_equal '3'
      _(xml['first_item_position']).must_equal '0'
      org = xml['result']['org'].first
      _(xml['result']['org'].length).must_equal 3
      _(org['name']).must_equal 'test name3'
      _(org['url']).must_equal "http://test.host/orgs/#{org3.vanity_url}.xml"
      _(org['html_url']).must_equal "http://test.host/orgs/#{org3.vanity_url}"
      _(org['description']).must_equal 'test description'
      _(org['vanity_url']).must_equal org3.vanity_url
      _(org['type']).must_equal 'Commercial'
      _(org['projects_count']).must_equal org3.projects_count.to_s
      _(org['affiliated_committers']).must_equal '0'
    end

    it 'should return unauthorized if api key is invalid' do
      get :index, params: { format: :xml, api_key: 'dummy_id' }
      assert_response :bad_request
    end
  end

  describe 'list_managers' do
    it 'should return managers' do
      login_as account
      create(:manage, target: organization, account: account)
      get :list_managers, params: { id: organization.id }
      assert_response :ok

      _(assigns(:managers)).must_equal [account]
    end
  end

  describe 'claim_projects_list' do
    it 'should return no projects without search term' do
      get :claim_projects_list, params: { id: organization.to_param }

      assert_response :ok

      _(assigns(:projects)).must_equal []
      _(assigns(:organization)).must_equal organization
    end

    it 'should return projects with search term' do
      login_as account
      pro1 = create(:project, name: 'test name1', organization_id: nil)
      pro2 = create(:project, name: 'test name2', organization_id: nil)
      pro3 = create(:project, name: 'test name3', organization_id: nil)

      get :claim_projects_list, params: { id: organization.to_param, query: 'test' }

      assert_response :ok

      _(assigns(:projects).pluck(:id).sort).must_equal [pro1.id, pro2.id, pro3.id].sort
      _(assigns(:organization)).must_equal organization
    end

    it 'should return projects with search term with sorting' do
      pro1 = create(:project, name: 'test name1')
      pro2 = create(:project, name: 'test name2')
      pro3 = create(:project, name: 'test name3')

      get :claim_projects_list, params: { id: organization.to_param, query: 'test', sort: 'new' }

      assert_response :ok

      _(assigns(:projects)).must_equal [pro3, pro2, pro1]
      _(assigns(:organization)).must_equal organization
    end
  end

  describe 'manage_projects' do
    it 'should return org managed projects' do
      pro1 = create(:project, name: 'test name1', organization_id: organization.id)
      pro2 = create(:project, name: 'test name2', organization_id: organization.id)
      pro3 = create(:project, name: 'test name3', organization_id: organization.id)

      get :manage_projects, params: { id: organization.to_param, query: 'test' }

      assert_response :ok

      _(assigns(:projects)).must_equal [pro3, pro2, pro1]
      _(assigns(:organization)).must_equal organization
    end

    it 'should return org managed projects with sorting' do
      pro1 = create(:project, name: 'test name1', organization_id: organization.id)
      pro2 = create(:project, name: 'test name2', organization_id: organization.id)
      pro3 = create(:project, name: 'test name3', organization_id: organization.id)

      get :manage_projects, params: { id: organization.to_param, query: 'test', sort: 'project_name' }

      assert_response :ok

      _(assigns(:projects)).must_equal [pro1, pro2, pro3]
      _(assigns(:organization)).must_equal organization
    end
  end

  describe 'claim_project' do
    it 'should claim a project for the given org' do
      login_as account
      pro1 = create(:project, name: 'test name1')
      get :claim_project, params: { id: organization.to_param, project_id: pro1.id }, xhr: true

      assert_response :ok
      _(assigns(:project).organization_id).must_equal organization.id
    end
  end

  describe 'remove_project' do
    before { login_as account }

    it 'should remove project from org' do
      pro1 = create(:project, name: 'test name1', organization_id: organization.id)

      put :remove_project, params: { id: organization.to_param, project_id: pro1.id, source: 'manage_projects' }

      assert_redirected_to manage_projects_organization_path(organization)
      _(flash[:success]).must_equal I18n.t('organizations.remove_project.success', name: pro1.name)
      _(pro1.reload.organization_id).must_be_nil
    end

    it 'should remove project from org and redirect to claim_projects_list' do
      pro1 = create(:project, name: 'test name1', organization_id: organization.id)

      put :remove_project, params: { id: organization.to_param, project_id: pro1.id, source: 'claim_projects_list' }

      assert_redirected_to claim_projects_list_organization_path(organization)
      _(flash[:success]).must_equal I18n.t('organizations.remove_project.success', name: pro1.name)
      _(pro1.reload.organization_id).must_be_nil
    end

    it 'must prevent unauthorized project removal' do
      restrict_edits_to_managers(organization)

      project = create(:project, name: 'test name1', organization_id: organization.id)

      put :remove_project, params: { id: organization.to_param, project_id: project.id, source: 'claim_projects_list' }

      assert_redirected_to organization_path(organization)
      _(flash[:notice]).must_equal I18n.t('organizations.unauthorized')
      _(project.reload.organization_id).must_equal organization.id
    end
  end

  describe 'new_manager' do
    it 'should show new manager form for get request' do
      login_as account
      get :new_manager, params: { id: organization, account_id: account.id }
      assert_response :ok
    end

    it 'should show new manager form for post request' do
      login_as account

      post :new_manager, params: { id: organization, account_id: account.id }

      assert_redirected_to list_managers_organization_path(organization)
      _(assigns(:manage).target).must_equal organization
    end

    it 'must prevent unauthorized manager creation' do
      restrict_edits_to_managers(organization)

      post :new_manager, params: { id: organization, account_id: account.id }

      assert_redirected_to organization_path(organization)
      _(flash[:notice]).must_equal I18n.t('organizations.unauthorized')
      _(organization.managers.pluck(:id)).must_be :empty?
    end
  end

  describe 'create' do
    it 'should show validation errors' do
      account.update_column(:level, 10)
      login_as account
      post :create, params: { organization: { name: 'test', description: 'tes', vanity_url: '',
                                              org_type: '2', homepage_url: 'http://test.com' } }

      assert_response :ok
      _(assigns(:organization).errors[:vanity_url]).must_equal ['can\'t be blank',
                                                                'is too short (minimum is 1 character)']
    end

    it 'should save record successfully' do
      account.update_column(:level, 10)
      login_as account
      post :create, params: { organization: { name: 'test', description: 'tes', vanity_url: 'test',
                                              org_type: '2', homepage_url: 'http://test.com' } }

      assert_redirected_to organization_path(assigns(:organization))
      _(assigns(:organization).valid?).must_equal true
    end

    it 'should gracefully handle duplicate vanity_urls' do
      old_org = create(:organization)
      account.update_column(:level, 10)
      login_as account
      post :create, params: { organization: { name: 'test', description: 'tes', vanity_url: old_org.vanity_url,
                                              org_type: '2', homepage_url: 'http://test.com' } }

      assert_response :ok
      _(assigns(:organization).errors[:vanity_url]).must_equal ['has already been taken']
    end
  end

  describe 'update' do
    it 'should show validation errors' do
      login_as account
      account.update_column(:level, 10)
      org = create(:organization, name: 'test')
      put :update, params: { id: org.id, organization: { name: '', description: 'tes', vanity_url: 'test',
                                                         org_type: '2', homepage_url: 'http://test.com' } }

      assert_response 422
      _(assigns(:organization).errors[:name]).must_equal ['can\'t be blank', 'is too short (minimum is 3 characters)']
    end

    it 'should save record successfully' do
      account.update_column(:level, 10)
      login_as account
      org = create(:organization, name: 'test')
      put :update, params: { id: org.id, organization: { name: 'test2', description: 'tes', vanity_url: 'test',
                                                         org_type: '2', homepage_url: 'http://test.com' } }

      assert_redirected_to organization_path(assigns(:organization))
      _(assigns(:organization).name).must_equal 'test2'
      _(assigns(:organization).valid?).must_equal true
    end
  end

  describe 'edit' do
    it 'should set organization' do
      login_as account
      account.update_column(:level, 10)
      org = create(:organization, name: 'test')
      get :edit, params: { id: org.id }
      _(assigns(:organization)).must_equal org
    end
  end

  describe 'new' do
    it 'should set new organization' do
      login_as account
      account.update_column(:level, 10)
      get :new
      _(assigns(:organization).new_record?).must_equal true
    end
  end

  describe 'claimed projects' do
    it 'should render show page if organization does not have any claimed projects' do
      get :projects, params: { id: organization.to_param }
      assert_response :redirect
      assert_redirected_to organization_path(organization)
    end

    it 'should render projects page if it has projects page' do
      create(:project, organization_id: organization.id)
      get :projects, params: { id: organization.to_param }
      assert_response :ok
      assert_template :projects
    end
  end
end
