# frozen_string_literal: true

require 'test_helper'

class Api::V1::ProjectsControllerTest < ActionController::TestCase
  include JWTHelper
  let(:api_key) { create(:api_key, account: create(:account)) }
  let(:client_id) { api_key.oauth_application.uid }
  let(:forge) { Forge.find_by(name: 'Github') }
  let(:enlistment_params) do
    { '0' => { code_location_attributes: { type: 'git', url: 'https://github.com/rails/rails',
                                           branch: 'main', scm_type: 'git' } } }
  end
  let(:project) { create(:project) }
  before do
    @account = create(:account)
    ENV['JWT_SECRET_API_KEY'] = Faker::Alphanumeric.alpha(number: 5)
    @jwt = build_jwt(@account.login, 24)
    @url = Faker::Internet.url
    @admin_jwt = build_jwt(create(:admin).login, 24)
  end

  describe 'create', type: :controller do
    it 'it should not create a project without editor account' do
      VCR.use_cassette('code_location_find_by_url') do
        url = 'git://github.com/rails/rails.git'
        post :create, params: { project: { JWT: @jwt, repo_url: url } }, format: :json
        WebMocker.github_api('https://api.github.com/repos/rails/rails', url)
        unmocked_create_enlistment_with_code_location(project, {}, url)
        expect(@response.content_type).must_equal 'application/json'
        _(response).wont_be :successful?
      end
    end

    it 'should create account with permission' do
      VCR.use_cassette('CreateProjectFromMatchURL, :record => :none') do
        @controller = Api::V1::ProjectsController.new
        stubs(:current_user).returns(@account)
        url = 'git://github.com/rails/rails.git'
        license = create(:license, vanity_url: 'rails')
        post :create, params: { JWT: @admin_jwt, repo_url: url,
                                license_name: license.name }, format: :json
        @controller.instance_eval { project_params }
        @controller.instance_eval { populate_project_from_forge('https://github.com/rails/rails', true) }
        login_as @account
        Enlistment.any_instance.stubs(:ensure_forge_and_job).returns(true)
        @controller.instance_eval { build_project }
        @controller.instance_eval { create_code_location_subscription }
        expect(@response.content_type).must_equal 'application/json'
      end
    end

    it 'wont be successful when given a bad JWT' do
      jwt = 'eyJhbGciOiJIUzI1.eyJleHBpcmF0aW9uIjoxNjMzMDI1NTcyLCJYWxleCJ9.whiDvp2KfeblCcMRnyskt7nehEcYKP5kEejkugIa0ko'
      post :create, params: { project: { JWT: jwt, url: @url } }, format: :json
      _(response).wont_be :successful?
    end
  end

  describe 'create#ValidationError', type: :controller do
    it 'it should handle duplicate project creation throw validation error' do
      VCR.use_cassette('CreateProjectFromMatchURL') do
        create(:project, name: 'rails', description: 'Ruby on Rails', vanity_url: 'rails')
        url = 'git://github.com/rails/rails.git'
        post :create, params: { JWT: @jwt, repo_url: url }, format: :json
        expect(@response.content_type).must_equal 'application/json'
        _(response).wont_be :successful?
      end
    end
  end

  describe 'create#fetchDescription', type: :controller do
    it 'it should fetch description from githubURl' do
      VCR.use_cassette('CreateProjectFromMatchURL, :record => :none') do
        project_data = Forge::Match.first('https://github.com/rails/rails').project
        controller = Api::V1::ProjectsController.new
        data = controller.populate_project_from_forge('https://github.com/rails/rails', true)
        _(project_data.description).must_match data.description
      end
    end
  end

  describe 'create# for bad request' do
    it 'it should not create a project without admin account' do
      VCR.use_cassette('code_location_find_by_url') do
        post :create, params: { JWT: @jwt }, format: :json
        expect(@response.content_type).must_equal 'application/json'
        assert_response :unauthorized
      end
    end

    it 'it should not create a project without editor account' do
      VCR.use_cassette('code_location_find_by_url') do
        post :create, params: { JWT: @admin_jwt }, format: :json
        expect(@response.content_type).must_equal 'application/json'
        assert_response :bad_request
      end
    end
  end

  describe '#similar' do
    it 'should return bad request if api key is not provided' do
      get :similar, params: { id: project.uuid, format: 'json' }
      assert_response :bad_request
      response = JSON.parse(@response.body)
      assert_equal response['error'], I18n.t(:missing_api_key)
    end

    it 'should return error if project not found' do
      get :similar, params: { id: project.id, format: 'json', api_key: client_id }
      assert_response :bad_request
      response = JSON.parse(@response.body)
      assert_equal response['error'], 'Project does not exist'
    end

    it 'should return no content if similar projects not found' do
      get :similar, params: { id: project.uuid, format: 'json', api_key: client_id }
      assert_response :no_content
      assert_empty JSON.parse(@response.body)['similar_projects']
    end

    it 'should return similar project' do
      project2 = create(:project)
      project3 = create(:project)
      tag = create(:tag)
      create(:tagging, tag: tag, taggable: project)
      create(:tagging, tag: tag, taggable: project2)
      create(:tagging, tag: tag, taggable: project3)

      get :similar, params: { id: project.uuid, format: 'json', api_key: client_id }
      assert_response :ok
      assert_not_empty JSON.parse(@response.body)['similar_projects']
    end
  end
end
