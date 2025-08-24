# frozen_string_literal: true

require 'test_helper'

class Api::V1::EnlistmentsControllerTest < ActionController::TestCase
  include JwtHelper

  before do
    WebMocker.get_code_location
    WebMocker.create_code_location
    @url = Faker::Internet.url
    @enlistment = create_random_enlistment(@url)
    @project_id = @enlistment.project_id
    @account = create(:admin)
    ENV['JWT_SECRET_API_KEY'] = Faker::Alphanumeric.alpha(number: 5)
    @jwt = build_jwt(@account.login, 24)
    Enlistment.any_instance.stubs(:update_subscription).returns(true)
    Project.any_instance.stubs(:guess_forge).returns(@enlistment.project.forge_match)
    Enlistment.any_instance.stubs(:ensure_forge_and_job).returns(true)
  end

  describe 'unsubscribe' do
    it 'should remove the enlistment' do
      _(@enlistment.deleted).must_equal false
      post :unsubscribe, params: { JWT: @jwt, url: @url, branch: 'main' }, format: :json
      _(response).must_be :successful?
      _(@enlistment.reload.deleted).must_equal true
    end

    it 'wont be successful when code location is not found' do
      post :unsubscribe, params: { JWT: @jwt, url: 'https://notacodelocation.biz', branch: 'main' }, format: :json
      _(response).wont_be :successful?
    end

    it 'wont be successful when given a bad JWT' do
      jwt = 'eyJhbGciOiJIUzI1.eyJleHBpcmF0aW9uIjoxNjMzMDI1NTcyLCJYWxleCJ9.whiDvp2KfeblCcMRnyskt7nehEcYKP5kEejkugIa0ko'
      post :unsubscribe, params: { JWT: jwt, url: @url, branch: 'main' }, format: :json
      _(response).wont_be :successful?
    end
  end

  it 'should remove the enlistment when code_location has no branch' do
    _(@enlistment.deleted).must_equal false
    Enlistment.connection.execute('update code_locations set module_branch_name = null where id ' \
                                  "= #{@enlistment.code_location_id}")
    post :unsubscribe, params: { JWT: @jwt, url: @url }, format: :json
    _(response).must_be :successful?
    _(@enlistment.reload).must_be :deleted
  end

  describe 'enlist' do
    it 'should create the enlistment' do
      VCR.use_cassette('create_code_location_subscription') do
        post :enlist, params: { JWT: @jwt, url: @url, branch: 'master', project: @project_id }, format: :json
        _(response).must_be :successful?
        @enlistment = Enlistment.where(project_id: @project_id, url: @url, branch: 'master')
      end
    end

    it 'must return errors when project is not valid' do
      post :enlist, params: { JWT: @jwt, url: @url, branch: 'master', project: '4938409' }, format: :json
      _(response).wont_be :successful?
    end

    it 'must return an error when given a bad JWT' do
      jwt = 'eyJhbGciOiJIUzI1.eyJleHBpcmF0aW9uIjoxNjMzMDI1NTcyLCJYWxleCJ9.whiDvp2KfeblCcMRnyskt7nehEcYKP5kEejkugIa0ko'
      post :enlist, params: { JWT: jwt, url: @url, branch: 'master', project: @project_id }, format: :json
      _(response).wont_be :successful?
    end
  end
end
